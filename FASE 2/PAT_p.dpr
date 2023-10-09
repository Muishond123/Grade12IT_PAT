program PAT_p;

uses
  Forms,
  WELCOME_u in 'WELCOME_u.pas' {frmWelcome},
  BUYER_u in 'BUYER_u.pas' {frmBuyer},
  MANAGER_u in 'MANAGER_u.pas' {frmManager},
  DM_u in 'DM_u.pas' {DmShop: TDataModule},
  clsBuyer in 'clsBuyer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDmShop, DmShop);
  Application.CreateForm(TfrmWelcome, frmWelcome);
  Application.CreateForm(TfrmBuyer, frmBuyer);
  Application.CreateForm(TfrmManager, frmManager);
  Application.Run;
end.
