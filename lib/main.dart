import "dart:developer";
import "dart:io";

import "package:dio/dio.dart";
import "package:dynamic_height_grid_view/dynamic_height_grid_view.dart";
import "package:flutter/material.dart";
import "package:flutter_web_demo/reqres.dart";
import "package:responsive_framework/responsive_framework.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return ResponsiveWrapper.builder(
          child,
          defaultScale: true,
          breakpoints: [
            /*const ResponsiveBreakpoint.resize(480, name: MOBILE),
            const ResponsiveBreakpoint.autoScale(800, name: TABLET),
            const ResponsiveBreakpoint.resize(1000, name: DESKTOP),
            const ResponsiveBreakpoint.autoScale(2460, name: "4K"),*/
            const ResponsiveBreakpoint.resize(480, name: MOBILE),
            const ResponsiveBreakpoint.resize(800, name: TABLET),
            const ResponsiveBreakpoint.resize(1000, name: DESKTOP),
            const ResponsiveBreakpoint.resize(2460, name: "4K"),
          ],
          defaultName: "defaultName",
          defaultNameLandscape: "defaultNameLandscape",
          background: Container(
            color: const Color(0xFFF5F5F5),
          ),
        );
      },
      home: const MyHomePage(),
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController controller = ScrollController();

  Future<Reqres>? future;

  @override
  void initState() {
    super.initState();
    getHttpResponse();
  }

  Future<Reqres> getHttpResponse() async {
    await Future.delayed(
      const Duration(seconds: 3),
    );
    Reqres response = await getHttp();
    future = Future.value(response);
    setState(() {});
    return Future.value(response);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ResponsiveWrapper.of(context).activeBreakpoint.name ?? "",
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Reqres>(
          future: future,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.done:
                return snapshot.hasError
                    ? Text(
                        snapshot.error.toString(),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(4),
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await getHttpResponse();
                            return Future.value();
                          },
                          child: isMobile()
                              ? mobileListView(snapshot)
                              : dynamicHeightGridView(snapshot, context),
                        ),
                      );
            }
          },
        ),
      ),
    );
  }

  Widget mobileListView(
    AsyncSnapshot<Reqres> snapshot,
  ) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: controller,
      itemCount: snapshot.data?.data?.length ?? 0,
      itemBuilder: (context, index) {
        Data data = snapshot.data?.data?[index] ?? Data();
        return Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            onTap: () {},
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: SizedBox(
                height: 50,
                width: 50,
                child: Image.network(
                  data.avatar ?? "",
                  loadingBuilder: (context, child, progress) {
                    return loadingBuilder(
                      context,
                      child,
                      progress,
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.error,
                    );
                  },
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${data.firstName ?? ""} ${data.lastName ?? ""}",
                  ),
                  Text(
                    data.email ?? "",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget dynamicHeightGridView(
    AsyncSnapshot<Reqres> snapshot,
    BuildContext context,
  ) {
    return DynamicHeightGridView(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: snapshot.data?.data?.length ?? 0,
      controller: controller,
      crossAxisCount: ResponsiveWrapper.of(context).isTablet ? 3 : 6,
      crossAxisSpacing: 2.0,
      mainAxisSpacing: 2.0,
      builder: (context, index) {
        Data data = snapshot.data?.data?[index] ?? Data();
        return Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            onTap: () {},
            title: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      data.avatar ?? "",
                      height: 50,
                      width: 50,
                      loadingBuilder: (context, child, progress) {
                        return loadingBuilder(
                          context,
                          child,
                          progress,
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.error,
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "${data.firstName ?? ""} ${data.lastName ?? ""}",
                      ),
                      Text(
                        data.email ?? "",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool isMobile() {
    bool isMobile = false;
    try {
      isMobile = (ResponsiveWrapper.of(context).isMobile ||
              Platform.isAndroid ||
              Platform.isIOS)
          ? true
          : false;
    } catch (e) {
      isMobile = false;
    }
    return isMobile;
  }

  Widget loadingBuilder(context, child, progress) {
    return (progress == null)
        ? child
        : Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
            ),
          );
  }

  Future<Reqres> getHttp() async {
    Reqres reqres = Reqres();
    try {
      Response<dynamic> response = await Dio().get(
        "https://reqres.in/api/users",
      );
      (response.statusCode == 200)
          ? reqres = Reqres.fromJson(response.data)
          : log("response.statusCode : ${response.statusCode}");
    } catch (e) {
      log("catch e : ${e.toString()}");
    }
    return Future.value(reqres);
  }
}
