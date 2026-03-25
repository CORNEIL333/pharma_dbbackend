import React, { useState } from 'react';
import { 
  QrCode, 
  Scan, 
  History, 
  Settings, 
  CheckCircle2, 
  Camera, 
  User, 
  LogOut,
  Wifi,
  WifiOff,
  AlertCircle
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

// --- Types & Mock Data ---

type Screen = 'pairing' | 'scanner' | 'history' | 'settings' | 'confirmation';
type Status = 'Entré' | 'Sorti' | 'En attente';

interface VisiteRecord {
  id: string;
  nom: string;
  prenom: string;
  service: string;
  timestamp: string;
  dossierNum: string;
  statut: Status;
}

const SERVICES = [
  "Urgences", "Consultation générale", "Pédiatrie", 
  "Maternité", "Cardiologie", "Radiologie", 
  "Chirurgie", "Neurologie"
];

// --- Components ---

const StatusBadge = ({ status }: { status: Status }) => {
  const colors = {
    'Entré': 'bg-[#1D9E75]/20 text-[#1D9E75]',
    'Sorti': 'bg-[#A32D2D]/20 text-[#A32D2D]',
    'En attente': 'bg-[#854F0B]/20 text-[#854F0B]'
  };
  return (
    <span className={`px-2 py-1 rounded text-[10px] font-bold uppercase ${colors[status]}`}>
      {status}
    </span>
  );
};

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('pairing');
  const [isConnected, setIsConnected] = useState(false);
  const [history, setHistory] = useState<VisiteRecord[]>([]);
  const [lastDossier, setLastDossier] = useState('P-2026-0001');
  const [scanData, setScanData] = useState({
    nom: '',
    prenom: '',
    typePiece: 'CNI',
    numPiece: '',
    dateNais: '',
    service: 'Urgences'
  });

  // Simulation de connexion WebSocket
  const handlePairing = () => {
    setIsConnected(true);
    setCurrentScreen('scanner');
  };

  const handleScan = () => {
    const newDossier = `P-2026-${Math.floor(Math.random() * 9000 + 1000)}`;
    setLastDossier(newDossier);
    
    const newRecord: VisiteRecord = {
      id: Date.now().toString(),
      nom: scanData.nom,
      prenom: scanData.prenom,
      service: scanData.service,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      dossierNum: newDossier,
      statut: 'Entré'
    };
    
    setHistory([newRecord, ...history]);
    setCurrentScreen('confirmation');
  };

  // --- Screens ---

  const PairingScreen = () => (
    <div className="flex flex-col items-center justify-center h-full p-6 text-center">
      <div className="absolute top-12 left-6 text-left">
        <h1 className="text-[#0F6E56] text-2xl font-bold">MedGate Mobile</h1>
        <p className="text-white/70 text-sm">Hôpital de Référence</p>
      </div>
      
      <div className="w-64 h-64 border-4 border-[#0F6E56] rounded-3xl flex items-center justify-center relative overflow-hidden group cursor-pointer" onClick={handlePairing}>
        <QrCode size={120} className="text-white/20 group-hover:text-[#0F6E56] transition-colors" />
        <div className="absolute inset-0 bg-gradient-to-b from-transparent via-[#0F6E56]/10 to-transparent animate-pulse" />
      </div>
      
      <div className="mt-10">
        <h2 className="text-white text-lg font-bold">Scanner le QR Code Desktop</h2>
        <p className="text-gray-500 text-sm mt-2">Cliquez sur le cadre pour simuler l'appairage</p>
      </div>
    </div>
  );

  const ScannerScreen = () => (
    <div className="flex flex-col h-full">
      <header className="p-4 flex items-center justify-center border-b border-white/5">
        <h2 className="font-bold">Scanner une pièce</h2>
      </header>
      
      <div className="flex-1 relative bg-black flex items-center justify-center">
        <div className="w-[80%] aspect-[1.58] border-2 border-white/30 rounded-xl relative">
          <div className="absolute -top-1 -left-1 w-4 h-4 border-t-2 border-l-2 border-[#0F6E56]" />
          <div className="absolute -top-1 -right-1 w-4 h-4 border-t-2 border-r-2 border-[#0F6E56]" />
          <div className="absolute -bottom-1 -left-1 w-4 h-4 border-b-2 border-l-2 border-[#0F6E56]" />
          <div className="absolute -bottom-1 -right-1 w-4 h-4 border-b-2 border-r-2 border-[#0F6E56]" />
        </div>
        
        <button 
          onClick={() => setScanData({
            nom: 'MBALLA',
            prenom: 'Jean-Marie',
            typePiece: 'CNI',
            numPiece: 'CM-1987-04-7731',
            dateNais: '12/04/1987',
            service: 'Urgences'
          })}
          className="absolute bottom-10 w-20 h-20 bg-[#0F6E56] rounded-full flex items-center justify-center shadow-lg shadow-[#0F6E56]/20 active:scale-95 transition-transform"
        >
          <Camera size={32} className="text-white" />
        </button>
      </div>

      {/* Simulation Form Overlay if data detected */}
      <AnimatePresence>
        {scanData.nom && (
          <motion.div 
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            className="absolute inset-0 bg-[#0F1117] z-20 overflow-y-auto p-6"
          >
            <div className="flex justify-between items-center mb-6">
              <h3 className="text-[#0F6E56] font-bold uppercase tracking-wider text-xs">Vérification des données</h3>
              <button onClick={() => setScanData({...scanData, nom: ''})} className="text-gray-500"><AlertCircle size={20} /></button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="text-xs text-gray-500 mb-1 block">NOM</label>
                <input 
                  className="w-full bg-[#161D18] border-none rounded-lg p-3 text-white focus:ring-1 ring-[#0F6E56]"
                  value={scanData.nom}
                  onChange={(e) => setScanData({...scanData, nom: e.target.value})}
                />
              </div>
              <div>
                <label className="text-xs text-gray-500 mb-1 block">PRÉNOM</label>
                <input 
                  className="w-full bg-[#161D18] border-none rounded-lg p-3 text-white focus:ring-1 ring-[#0F6E56]"
                  value={scanData.prenom}
                  onChange={(e) => setScanData({...scanData, prenom: e.target.value})}
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-xs text-gray-500 mb-1 block">DATE NAISSANCE</label>
                  <input 
                    className="w-full bg-[#161D18] border-none rounded-lg p-3 text-white focus:ring-1 ring-[#0F6E56]"
                    value={scanData.dateNais}
                    onChange={(e) => setScanData({...scanData, dateNais: e.target.value})}
                  />
                </div>
                <div>
                  <label className="text-xs text-gray-500 mb-1 block">TYPE PIÈCE</label>
                  <select className="w-full bg-[#161D18] border-none rounded-lg p-3 text-white focus:ring-1 ring-[#0F6E56]">
                    <option>CNI</option>
                    <option>Passeport</option>
                  </select>
                </div>
              </div>
              
              <div className="pt-4">
                <label className="text-xs text-gray-500 mb-2 block">SERVICE HOSPITALIER</label>
                <div className="flex flex-wrap gap-2">
                  {SERVICES.map(s => (
                    <button 
                      key={s}
                      onClick={() => setScanData({...scanData, service: s})}
                      className={`px-3 py-2 rounded-full text-xs transition-colors ${scanData.service === s ? 'bg-[#0F6E56] text-white' : 'bg-[#161D18] text-gray-400'}`}
                    >
                      {s}
                    </button>
                  ))}
                </div>
              </div>

              <button 
                onClick={handleScan}
                className="w-full bg-[#0F6E56] text-white font-bold py-4 rounded-xl mt-8 active:scale-[0.98] transition-transform"
              >
                ENVOYER AU DESKTOP
              </button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );

  const ConfirmationScreen = () => (
    <div className="flex flex-col items-center justify-center h-full p-8 text-center bg-[#0F1117]">
      <motion.div 
        initial={{ scale: 0 }}
        animate={{ scale: 1 }}
        className="text-[#1D9E75] mb-6"
      >
        <CheckCircle2 size={100} />
      </motion.div>
      
      <h2 className="text-2xl font-bold text-white mb-2">Envoi Réussi</h2>
      <p className="text-gray-500 text-sm mb-10">Le dossier a été créé sur le poste de travail</p>
      
      <div className="w-full bg-[#161D18] border border-[#0F6E56]/30 rounded-2xl p-6 mb-12">
        <p className="text-[10px] text-gray-500 font-bold tracking-widest mb-2">NUMÉRO DE DOSSIER</p>
        <p className="text-3xl font-bold text-[#0F6E56] tracking-widest">{lastDossier}</p>
      </div>
      
      <button 
        onClick={() => {
          setScanData({ ...scanData, nom: '' });
          setCurrentScreen('scanner');
        }}
        className="w-full bg-[#0F6E56] text-white font-bold py-4 rounded-xl active:scale-[0.98] transition-transform"
      >
        NOUVEAU SCAN
      </button>
    </div>
  );

  const HistoryScreen = () => (
    <div className="flex flex-col h-full">
      <header className="p-4 flex items-center justify-between border-b border-white/5">
        <div className="w-8" />
        <h2 className="font-bold">Historique des scans</h2>
        <button onClick={() => setHistory([])} className="text-gray-500"><AlertCircle size={20} /></button>
      </header>
      
      <div className="flex-1 overflow-y-auto p-4 space-y-3">
        {history.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-full opacity-20">
            <History size={64} />
            <p className="mt-4">Aucun scan récent</p>
          </div>
        ) : (
          history.map(item => (
            <div key={item.id} className="bg-[#161D18] p-4 rounded-xl flex items-center gap-4">
              <div className="w-12 h-12 bg-[#0F6E56]/10 rounded-lg flex items-center justify-center text-[#0F6E56]">
                <User size={24} />
              </div>
              <div className="flex-1">
                <h4 className="font-bold text-sm">{item.nom} {item.prenom}</h4>
                <p className="text-[11px] text-gray-500">{item.service} • {item.dossierNum}</p>
              </div>
              <div className="text-right">
                <p className="text-[10px] text-gray-500 mb-2">{item.timestamp}</p>
                <StatusBadge status={item.statut} />
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );

  const SettingsScreen = () => (
    <div className="flex flex-col h-full">
      <header className="p-4 flex items-center justify-center border-b border-white/5">
        <h2 className="font-bold">Paramètres</h2>
      </header>
      
      <div className="p-6 space-y-6">
        <div>
          <h3 className="text-[#0F6E56] text-[10px] font-bold tracking-widest mb-3">CONNEXION DESKTOP</h3>
          <div className="bg-[#161D18] rounded-xl p-4 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className={isConnected ? "text-green-500" : "text-red-500"}>
                {isConnected ? <Wifi size={20} /> : <WifiOff size={20} />}
              </div>
              <div>
                <p className="text-sm font-bold">{isConnected ? "Connecté au serveur" : "Déconnecté"}</p>
                <p className="text-xs text-gray-500">192.168.1.45:8080</p>
              </div>
            </div>
            {isConnected && <CheckCircle2 size={20} className="text-green-500" />}
          </div>
        </div>

        <div>
          <h3 className="text-[#0F6E56] text-[10px] font-bold tracking-widest mb-3">SÉCURITÉ</h3>
          <div className="bg-[#161D18] rounded-xl overflow-hidden">
            <div className="p-4 flex items-center justify-between border-b border-white/5">
              <div className="flex items-center gap-3">
                <QrCode size={20} className="text-gray-400" />
                <span className="text-sm">Token de session</span>
              </div>
              <span className="text-xs text-gray-500">MG-882-X</span>
            </div>
            <button 
              onClick={() => {
                setIsConnected(false);
                setCurrentScreen('pairing');
              }}
              className="w-full p-4 flex items-center gap-3 text-red-500 active:bg-red-500/10 transition-colors"
            >
              <LogOut size={20} />
              <span className="text-sm font-bold">Déconnecter l'appareil</span>
            </button>
          </div>
        </div>

        <div className="pt-10 text-center">
          <p className="text-[10px] text-gray-600 uppercase tracking-widest">MedGate Cameroon • v1.0.0</p>
        </div>
      </div>
    </div>
  );

  // --- Main Layout ---

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-900 font-sans">
      {/* Mobile Frame Simulation */}
      <div className="w-[375px] h-[700px] bg-[#0F1117] text-[#F0F0F0] rounded-[3rem] shadow-2xl border-[8px] border-gray-800 relative overflow-hidden flex flex-col">
        
        {/* Status Bar Simulation */}
        <div className="h-10 flex items-center justify-between px-8 pt-2">
          <span className="text-xs font-bold">9:41</span>
          <div className="flex items-center gap-1">
            <div className="w-4 h-2 border border-white/30 rounded-sm" />
            <Wifi size={12} />
          </div>
        </div>

        {/* Screen Content */}
        <div className="flex-1 overflow-hidden">
          {currentScreen === 'pairing' && <PairingScreen />}
          {currentScreen === 'scanner' && <ScannerScreen />}
          {currentScreen === 'confirmation' && <ConfirmationScreen />}
          {currentScreen === 'history' && <HistoryScreen />}
          {currentScreen === 'settings' && <SettingsScreen />}
        </div>

        {/* Bottom Navigation */}
        {currentScreen !== 'pairing' && currentScreen !== 'confirmation' && (
          <div className="h-20 bg-[#161D18] border-t border-white/5 flex items-center justify-around px-4 pb-4">
            <button 
              onClick={() => setCurrentScreen('scanner')}
              className={`flex flex-col items-center gap-1 ${currentScreen === 'scanner' ? 'text-[#0F6E56]' : 'text-gray-500'}`}
            >
              <Scan size={24} />
              <span className="text-[10px] font-bold">Scanner</span>
            </button>
            <button 
              onClick={() => setCurrentScreen('history')}
              className={`flex flex-col items-center gap-1 relative ${currentScreen === 'history' ? 'text-[#0F6E56]' : 'text-gray-500'}`}
            >
              <History size={24} />
              <span className="text-[10px] font-bold">Historique</span>
              {history.length > 0 && (
                <span className="absolute top-0 right-2 w-4 h-4 bg-orange-600 text-white text-[8px] rounded-full flex items-center justify-center font-bold">
                  {history.length}
                </span>
              )}
            </button>
            <button 
              onClick={() => setCurrentScreen('settings')}
              className={`flex flex-col items-center gap-1 relative ${currentScreen === 'settings' ? 'text-[#0F6E56]' : 'text-gray-500'}`}
            >
              <Settings size={24} />
              <span className="text-[10px] font-bold">Paramètres</span>
              {isConnected && (
                <span className="absolute top-0 right-2 w-2 h-2 bg-green-500 rounded-full" />
              )}
            </button>
          </div>
        )}

        {/* Home Indicator */}
        <div className="absolute bottom-2 left-1/2 -translate-x-1/2 w-32 h-1 bg-white/20 rounded-full" />
      </div>
    </div>
  );
}
