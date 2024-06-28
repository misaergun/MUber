import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:users_app/infoHandler/app_info.dart';
import 'package:users_app/widgets/history_design_ui.dart';

class TripsHistoryScreen extends StatefulWidget {
  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Trips History"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            SystemNavigator.pop();
          },
        ),
      ),
      body: Consumer<AppInfo>(
        builder: (context, appInfo, child) {
          if (appInfo.allTripsHistoryInformationList.isEmpty) {
            return Center(
              child: Text(
                "No trips history available.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView.separated(
            separatorBuilder: (context, i) => const Divider(
              color: Colors.grey,
              thickness: 2,
              height: 2,
            ),
            itemBuilder: (context, i) {
              final trip = appInfo.allTripsHistoryInformationList[i];
              if (trip == null) {
                return SizedBox.shrink(); // Eğer trip null ise, boş bir widget döndür
              }
              return Card(
                color: Colors.white54,
                child: HistoryDesignUIWidget(
                  tripsHistoryModel: trip,
                ),
              );
            },
            itemCount: appInfo.allTripsHistoryInformationList.length,
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
          );
        },
      ),
    );
  }
}
