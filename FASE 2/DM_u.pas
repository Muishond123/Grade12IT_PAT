unit DM_u;

interface

uses
  SysUtils, Classes, DB, ADODB;

type
  TDmShop = class(TDataModule)
    conShop: TADOConnection;
    qryProducts: TADOQuery;
    dsProducts: TDataSource;
    dsBuyer: TDataSource;
    tblBuyer: TADOTable;
    dsSales: TDataSource;
    tblSales: TADOTable;
    tblProducts: TADOTable;
    qrySales: TADOQuery;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DmShop: TDmShop;

implementation
uses
WELCOME_u, BUYER_u,MANAGER_u;

{$R *.dfm}

end.
