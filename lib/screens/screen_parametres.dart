import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class ScreenParametres extends StatelessWidget {
  const ScreenParametres({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final session = appState.session;

    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader("CONNEXION DESKTOP"),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(
                appState.isConnected ? Icons.link : Icons.link_off,
                color: appState.isConnected ? Colors.green : Colors.red,
              ),
              title: Text(appState.isConnected ? "Connecté au serveur" : "Déconnecté"),
              subtitle: Text(session != null ? "${session.ip}:${session.port}" : "Non configuré"),
              trailing: appState.isConnected 
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader("SÉCURITÉ"),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.vpn_key),
                  title: const Text("Token de session"),
                  subtitle: Text(session != null ? session.token : "N/A"),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Déconnecter l'appareil", style: TextStyle(color: Colors.red)),
                  onTap: () => _showDisconnectDialog(context, appState),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader("APPLICATION"),
          const SizedBox(height: 10),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text("Version"),
                  trailing: Text("1.0.0 (Build 2026)", style: TextStyle(color: Colors.grey)),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.location_hospital),
                  title: Text("Hôpital"),
                  trailing: Text("MedGate Cameroon", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              "Développé par MedGate Systems",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion ?"),
        content: const Text("Vous devrez scanner à nouveau le QR code pour vous reconnecter."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER")),
          TextButton(
            onPressed: () {
              appState.disconnect();
              Navigator.pop(context);
              context.go('/');
            },
            child: const Text("DÉCONNECTER", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
