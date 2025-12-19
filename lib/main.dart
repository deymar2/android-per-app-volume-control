import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: VolControlApp()
));

class VolControlApp extends StatefulWidget {
  const VolControlApp({super.key});

  @override
  State<VolControlApp> createState() => _VolControlAppState();
}

class _VolControlAppState extends State<VolControlApp> {
  static const platform = MethodChannel('com.tuapp/volumen');
  List<AppConfig> _selectedApps = []; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? appsJson = prefs.getString('selected_apps');
    if (appsJson != null) {
      final List decode = json.decode(appsJson);
      setState(() {
        _selectedApps = decode.map((item) => AppConfig.fromJson(item)).toList();
      });
      _updateNativeService();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encode = json.encode(_selectedApps.map((e) => e.toJson()).toList());
    await prefs.setString('selected_apps', encode);
    _updateNativeService();
  }

  Future<void> _updateNativeService() async {
    try {
      Map<String, double> volumeMap = {
        for (var app in _selectedApps) app.packageName: app.volume
      };
      await platform.invokeMethod('updateConfig', volumeMap);
    } on PlatformException catch (e) {
      debugPrint("Error comunicando con Android: ${e.message}");
    }
  }

  void _openAppSelector() async {
    List<AppInfo> allApps = await InstalledApps.getInstalledApps(
      excludeSystemApps: false, // Ahora Chrome y apps de sistema aparecerán
      withIcon: true
    );
    
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, controller) => ListView.builder(
          controller: controller,
          itemCount: allApps.length,
          itemBuilder: (context, index) {
            final appInfo = allApps[index];
            return ListTile(
              leading: appInfo.icon != null ? Image.memory(appInfo.icon!, width: 35) : const Icon(Icons.android),
              title: Text(appInfo.name),
              onTap: () {
                setState(() {
                  if (!_selectedApps.any((element) => element.packageName == appInfo.packageName)) {
                    _selectedApps.add(AppConfig(
                      name: appInfo.name,
                      packageName: appInfo.packageName,
                      volume: 0.5,
                    ));
                    _saveData();
                  }
                });
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Control de Volumen Apps"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _openAppSelector)],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _selectedApps.isEmpty
          ? const Center(child: Text("Lista vacía. Añade apps con (+)", textAlign: TextAlign.center))
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _selectedApps.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _selectedApps.removeAt(oldIndex);
                  _selectedApps.insert(newIndex, item);
                  _saveData();
                });
              },
              itemBuilder: (context, index) {
                final app = _selectedApps[index];
                return Dismissible(
                  key: ValueKey("dismiss_${app.packageName}"),
                  background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                  onDismissed: (_) { setState(() { _selectedApps.removeAt(index); _saveData(); }); },
                  child: Card(
                    key: ValueKey(app.packageName),
                    child: ExpansionTile(
                      title: Text(app.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Volumen: ${(app.volume * 100).toInt()}%"),
                      trailing: const Icon(Icons.drag_handle),
                      children: [
                        Slider(
                          value: app.volume,
                          onChanged: (val) => setState(() => app.volume = val),
                          onChangeEnd: (val) => _saveData(),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class AppConfig {
  String name;
  String packageName;
  double volume;
  AppConfig({required this.name, required this.packageName, required this.volume});
  Map<String, dynamic> toJson() => {'name': name, 'packageName': packageName, 'volume': volume};
  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(name: json['name'], packageName: json['packageName'], volume: json['volume']);
}