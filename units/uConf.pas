unit uConf;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, inifiles, printers,
  Vcl.Buttons, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL,
  FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB;

type
  TForm3 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet4: TTabSheet;
    LbeBanco: TLabeledEdit;
    CbxDriverBanco: TComboBox;
    Label1: TLabel;
    LbUsuario: TLabeledEdit;
    LbeServidor: TLabeledEdit;
    LbSenha: TLabeledEdit;
    cbxCharacter: TComboBox;
    Label2: TLabel;
    BtnOK: TSpeedButton;
    BtnCancelar: TSpeedButton;
    LbePorta: TLabeledEdit;
    CbxSSL: TComboBox;
    Label3: TLabel;
    CbxUsaTEF: TComboBox;
    Label4: TLabel;
    LbeIniTEF: TLabeledEdit;
    LbeCaminhoTEF: TLabeledEdit;
    TabSheet5: TTabSheet;
    GroupBox3: TGroupBox;
    LbeRetornoAcbr: TLabeledEdit;
    LbeSolicitaAcbr: TLabeledEdit;
    LbeUltimaNota: TLabeledEdit;
    LbeTerminal: TLabeledEdit;
    FDCon: TFDConnection;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    GroupBox2: TGroupBox;
    LabeledEdit1: TLabeledEdit;
    CbxImpressora: TComboBox;
    GroupBox1: TGroupBox;
    LabeledEdit2: TLabeledEdit;
    ChbxPrevisualizaimpressao: TCheckBox;
    ChbxUsarBalansa: TCheckBox;
    Shape1: TShape;
    Panel1: TPanel;
    LbFechar: TLabel;
    GroupBox4: TGroupBox;
    BtnTestaConexao: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure CarregaConectaBanco;
    procedure CarregainiNFE;
    procedure LbePortaKeyPress(Sender: TObject; var Key: Char);
    procedure CarregarImpressoras;
    procedure BtnTestaConexaoClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure SalvaConexaoBanco;
    procedure BtnOKClick(Sender: TObject);
    procedure SalvariniNFE;
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LbFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    iniApp,iniNFe : TIniFile;
    ConectaBanco : TStringList;
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}
FUNCTION CriptografarString(aTexto : string;criptografando : boolean):string;external'pluginramo.dll';

procedure TForm3.BtnCancelarClick(Sender: TObject);
begin
if iniApp <> nil then iniApp.Free;
if iniNFe <> nil then iniNFe.Free;
close;
end;

procedure TForm3.BtnOKClick(Sender: TObject);
begin
SalvaConexaoBanco;
SalvariniNFE;
application.MessageBox('configura��es salvas com Suscesso!','configura��es',64);
end;

procedure TForm3.BtnTestaConexaoClick(Sender: TObject);
begin
FDCon.Connected:= false;
FDCon.Params.Clear;
FDCon.Params.Text :=
'DriverID='+CbxDriverBanco.Text +#13+
'Server='+LbeServidor.Text+#13+
'database='+ LbeBanco.Text+#13+
'User_Name='+LbUsuario.Text+#13+
'Password='+LbSenha.Text+#13+
'CharacterSet='+ cbxCharacter.Text+#13+
'Port='+LbePorta.Text+#13+
'UseSSL='+CbxSSL.Text;
//showmessage(fdcon.Params.Text);
try
FDCon.Connected:= true;
application.MessageBox('Conectado com Suscesso!','Teste de Conex�o',64);
except
on e:exception do
application.MessageBox(pwchar('Falha na Conex�o'+#13+e.message),'Teste de Conex�o',16);
end;
FDCon.Connected := false;
end;

procedure TForm3.CarregaConectaBanco;
begin
CbxDriverBanco.Text := ConectaBanco.Values['DriverID'];
LbeServidor.Text := ConectaBanco.Values['Server'];
LbeBanco.Text := ConectaBanco.Values['database'];
LbUsuario.Text := ConectaBanco.Values['User_Name'];
LbSenha.Text := CriptografarString(ConectaBanco.Values['password'],false);
cbxCharacter.Text := ConectaBanco.Values['CharacterSet'];
LbePorta.Text := ConectaBanco.Values['Port'];
CbxSSL.Text := ConectaBanco.Values['UseSSL'];

end;

procedure TForm3.CarregainiNFE;
begin
//CbxUsaTEF.ItemIndex :=-1;
CbxUsaTEF.ItemIndex := ininfe.ReadInteger('venda','usarTEF',0);

LbeIniTEF.Text := iniNFE.ReadString('Ajustes_TEF','arqIni_TEF','');
LbeTerminal.Text := iniNFE.Readstring('Venda', 'Terminal', '');
LbeUltimaNota.Text := iniNFe.ReadString('Dados_NFE', 'UltimaNota', '');

CbxUsaTEF.ItemIndex := iniNFE.ReadInteger('venda', 'UsarBalConectada', 0);

LbeSolicitaAcbr.Text := iniNFe.ReadString('root', 'saida', '');
LbeRetornoAcbr.Text :=iniNFe.ReadString('root', 'Retorno', '');
CbxImpressora.ItemIndex := CbxImpressora.Items.IndexOf(iniNFe.ReadString('impressao','impressora',''));
 ChbxUsarBalansa.Checked := iniNFE.ReadInteger('Balanca', 'UsarBalConectada', 0)=1;
 ChbxPrevisualizaimpressao.Checked := iniNFe.ReadInteger('impressao','Previsualizar',0) = 1;

end;

procedure TForm3.CarregarImpressoras;
var
i:integer;
begin
//for I := 0 to Printer.Printers.Count-1 do
 begin
 CbxImpressora.Items := printer.Printers;
 end;


end;

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
begin
action := cafree;
form3 := nil;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
 iniApp := TInifile.Create(extractfilepath(application.ExeName)+'config.ini');
 iniNFe := TInifile.Create(extractfilepath(application.ExeName)+'configNFE.ini');

 ConectaBanco :=TStringList.Create;
 ConectaBanco.LoadFromFile(extractfilepath(application.ExeName)+'Conectabanco.inf');
    CarregarImpressoras;
 CarregaConectaBanco;
 CarregainiNFE;


end;

procedure TForm3.LbePortaKeyPress(Sender: TObject; var Key: Char);
begin
if not (key in['0'..'9',#13,#8]) then  Key:= #0;

end;

procedure TForm3.LbFecharClick(Sender: TObject);
begin
self.Close;
end;

procedure TForm3.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 ReleaseCapture;

  { Move o panel }
  PostMessage(self.Handle, WM_SYSCOMMAND, $F012, 0);
end;

procedure TForm3.SalvaConexaoBanco;
begin
ConectaBanco.Text :=
'DriverID='+CbxDriverBanco.Text +#13+
'Server='+LbeServidor.Text+#13+
'database='+ LbeBanco.Text+#13+
'User_Name='+LbUsuario.Text+#13+
'Password='+CriptografarString(LbSenha.Text,true)+#13+
'CharacterSet='+ cbxCharacter.Text+#13+
'Port='+LbePorta.Text+#13+
'UseSSL='+CbxSSL.Text;
 ConectaBanco.SaveToFile(ExtractFilePath(application.ExeName)+'Conectabanco.inf');
end;

procedure TForm3.SalvariniNFE;
begin
ininfe.WriteInteger('venda','usarTEF',CbxUsaTEF.ItemIndex);

 iniNFE.WriteString('Ajustes_TEF','arqIni_TEF',LbeIniTEF.Text);
 iniNFE.WriteString('Venda', 'Terminal', LbeTerminal.Text);
 iniNFe.WriteString('Dados_NFE', 'UltimaNota', LbeUltimaNota.Text);

 iniNFe.WriteString('root', 'saida', LbeSolicitaAcbr.Text);
 iniNFe.WriteString('root', 'Retorno', LbeRetornoAcbr.Text);
 iniNFe.WriteString('impressao','impressora',CbxImpressora.text);
 iniNFE.WriteInteger('Balanca', 'UsarBalConectada', integer(ChbxUsarBalansa.Checked));
 iniNFe.WriteInteger('impressao','Previsualizar',integer(ChbxPrevisualizaimpressao.Checked));

end;

end.
