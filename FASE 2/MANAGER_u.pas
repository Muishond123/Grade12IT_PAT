unit MANAGER_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, DBGrids, ComCtrls, StdCtrls, jpeg, Buttons, Spin;

type
  TfrmManager = class(TForm)
    pgcManager: TPageControl;
    tbsProducts: TTabSheet;
    tbsHistory: TTabSheet;
    dbgProducts: TDBGrid;
    pnlEdit: TPanel;
    pnlDelete: TPanel;
    lblFilter: TLabel;
    cmbFilter: TComboBox;
    redDisplay: TRichEdit;
    pnlSales: TPanel;
    imgBackgroundProducts: TImage;
    imgBackgroundHistory: TImage;
    pnlChange: TPanel;
    bbnExit: TBitBtn;
    bbnReturn: TBitBtn;
    bbnHelp: TBitBtn;
    pnlAdd: TPanel;
    lblSort: TLabel;
    cmbSort: TComboBox;
    pnlApply: TPanel;
    bbnReset: TBitBtn;
    pnlInputs: TPanel;
    cmbCategory: TComboBox;
    edtPName: TEdit;
    EdtPDescription: TEdit;
    sedQuantity: TSpinEdit;
    sedEcoP: TSpinEdit;
    sedPrice: TSpinEdit;
    lblHeading: TLabel;
    lblPName: TLabel;
    lblDescription: TLabel;
    lblCategory: TLabel;
    lblQuantity: TLabel;
    lblEcoP: TLabel;
    lblPrice: TLabel;
    pnlSave: TPanel;
    bbnBack: TBitBtn;
    dbgSales: TDBGrid;
    pnlHelp: TPanel;
    redHelp: TRichEdit;
    bbnHelpCancel: TBitBtn;
    cmbFilterSales: TComboBox;
    lblFilterSales: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure bbnExitClick(Sender: TObject);
    procedure pnlApplyClick(Sender: TObject);
    procedure bbnResetClick(Sender: TObject);
    procedure pnlAddClick(Sender: TObject);
    procedure pnlSaveClick(Sender: TObject);
    procedure bbnBackClick(Sender: TObject);
    procedure pnlEditClick(Sender: TObject);
    procedure pnlDeleteClick(Sender: TObject);
    procedure bbnReturnClick(Sender: TObject);
    procedure pgcManagerChange(Sender: TObject);
    procedure pnlSalesClick(Sender: TObject);
    procedure pnlChangeClick(Sender: TObject);
    procedure bbnHelpClick(Sender: TObject);
    procedure bbnHelpCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmManager: TfrmManager;
  bEdit:boolean;

implementation
uses
WELCOME_U, DM_u;
{$R *.dfm}

procedure TfrmManager.bbnBackClick(Sender: TObject);
begin
pnlInputs.Visible:=false;                                                       //Makes panel invissable
//The next lines clear all the input fields
edtPName.Text:='';
EdtPDescription.Text:='';
cmbCategory.ItemIndex:=-1;
sedQuantity.Value:=0;
sedEcoP.Value:=1;
sedPrice.Value:=1;
end;

procedure TfrmManager.bbnExitClick(Sender: TObject);
begin
Application.MainForm.Close;                                                     //Closes the whole program
end;

procedure TfrmManager.bbnHelpClick(Sender: TObject);
begin
pgcManager.ActivePage:=tbsProducts;
pnlHelp.Visible:=true;
redHelp.Lines.LoadFromFile('ManagerHelp.txt');
end;

procedure TfrmManager.bbnResetClick(Sender: TObject);
begin
DmShop.qryProducts.SQL.Clear;                                                   //Clears all the SQL instructions so that new instructions can be given
DmShop.qryProducts.Active:=false;                                               //Deactivates the ADOquery component
DmShop.qryProducts.SQL.Add('SELECT ProductID ,ProductName, Price, EcoPoints,'+  //sql Query: Show the 5 spesified fields, filtered and sorted by the user's inputs
'Category, Description FROM tblProducts');
DmShop.qryProducts.Active:=true;                                                //Activates the ADOquery component

cmbFilter.ItemIndex:=-1;                                                        //Resets the combobox
cmbSort.ItemIndex:=-1;                                                          //Resets the combobox
end;

procedure TfrmManager.bbnReturnClick(Sender: TObject);
begin
frmManager.Hide;
frmWelcome.Show;
end;

procedure TfrmManager.bbnHelpCancelClick(Sender: TObject);
begin
pnlHelp.Visible:=false;
end;

procedure TfrmManager.FormActivate(Sender: TObject);
begin
pgcManager.ActivePage:=tbsProducts;                                             //Displays the store page when the buyer form activates
dbgProducts.DataSource:=DmShop.dsProducts;                                      //Changes the dbGrid's data source to the products datasource
DmShop.qryProducts.SQL.Clear;                                                   //Clears all the SQL instructions so that new instructions can be given
DmShop.qryProducts.Active:=false;                                               //Deactivates the ADOquery component
DmShop.qryProducts.SQL.Add('SELECT ProductID,ProductName, Price, EcoPoints,'+   //SQL query is being sent to the ADOQuery component
' Category, Description FROM tblProducts');
DmShop.qryProducts.Active:=true;                                                //Activates the ADOquery component

bEdit:=false;                                                                   //Boolean variable that is initialised for later use in program
end;

procedure TfrmManager.pgcManagerChange(Sender: TObject);
begin
if pgcManager.ActivePage=tbsHistory then
begin
  dbgSales.Visible:=false;
end;

end;

procedure TfrmManager.pnlAddClick(Sender: TObject);
begin
pnlInputs.Visible:=true;                                                        //Turns the panel vissible for user\
end;

procedure TfrmManager.pnlApplyClick(Sender: TObject);
var
sSql, sFilter, sSort:string;
begin

if (cmbFilter.ItemIndex<>-1) AND (cmbSort.ItemIndex<>-1) then                   //If the user selected an item in both the comboboxes
begin
sFilter:=cmbFilter.Items[cmbFilter.ItemIndex];                                  //The sFilter variable gets the value of the selected item in the combobx
sSort:=cmbSort.Items[cmbSort.ItemIndex];                                        //The sOrder variable gets the value of the selected item in the combobx
sSql:='SELECT ProductID ,ProductName, Price, EcoPoints, Category, Description '+//sql Query: Show the 5 spesified fields, filtered and sorted by the user's inputs
'FROM tblProducts WHERE Category = "'+sFilter+'" Order By '+sSort;
end
else
if cmbFilter.ItemIndex<>-1 then                                                 //If the user only selected an item in the Filter the combobox
begin
sFilter:=cmbFilter.Items[cmbFilter.ItemIndex];                                  //The sFilter variable gets the value of the selected item in the combobx
sSql:='SELECT ProductID, ProductName, Price, EcoPoints, Category, Description '+ //sql Query: Show the 5 spesified fields, filtered user's input
'FROM tblProducts WHERE Category = "'+sFilter+'"';
end
else
if cmbSort.ItemIndex<>-1 then                                                   //If the user only selected an item in the Sort the combobox
begin
sSort:=cmbSort.Items[cmbSort.ItemIndex];                                        //The sFilter variable gets the value of the selected item in the combobx
sSql:='SELECT ProductID, ProductName, Price, EcoPoints, Category, Description '+ //sql Query: Show the 5 spesified fields, sorted by the user's input
'FROM tblProducts ORDER BY '+sSort;
end
else
if (cmbFilter.ItemIndex=-1) AND (cmbSort.ItemIndex=-1) then                     //If the user didnt select any option out of any of the comboboxes
begin
showmessage('You should select at least 1 options from 1 of the comboboxes '+   //Shows this message:
'before you can apply any changes to the table');
exit;                                                                           //Exits out of the click panel event
end;

DmShop.qryProducts.SQL.Clear;                                                   //Clears all the SQL instructions so that new instructions can be given
DmShop.qryProducts.Active:=false;                                               //Deactivates the ADOquery component
DmShop.qryProducts.SQL.Add(sSql);                                               //SQL query is being sent to the ADOQuery component
DmShop.qryProducts.Active:=true;                                                //Activates the ADOquery component

end;

procedure TfrmManager.pnlChangeClick(Sender: TObject);
begin
dbgSales.Visible:=false;
redDisplay.Lines.LoadFromFile('Changes.txt');
end;

procedure TfrmManager.pnlDeleteClick(Sender: TObject);
var
sPID:string;
bFound:boolean;
tFile:textfile;
begin
sPID:=InputBox('Product ID','Please enter the ID of the product you wish to delete ',''); //Stores user's input in string variable
bfound:=false;                                                                  //False boolean variable indicates that a match for the user's input has not been found

DmShop.tblSales.First;                                                          //Moves cursor to the first record of the database table
while (not DmShop.tblSales.Eof) do                                              //Loop that will run to the end of the table or till a match has been found for theID the user entered
begin
  if DmShop.tblSales['ProductID']=sPID then                                     //If a match for the Product ID has been found:
  begin
  DmShop.tblSales.Delete
  end
  else
  DmShop.tblsales.Next;                                                      //Moves cursor to the next record in the table
end;

DmShop.tblProducts.First;                                                       //Moves cursor to the first record of the database table
while (not DmShop.tblProducts.Eof) AND (bfound=false) do                        //Loop that will run to the end of the table or till a match has been found for theID the user entered
begin
  if DmShop.tblProducts['ProductID']=sPID then                                  //If a match for the Product ID has been found:
  begin
    DmShop.tblProducts.Delete;
    bfound:=true;                                                               //True boolean variable indicates that a match has been found
  end
  else
  begin
  DmShop.tblProducts.Next;                                                      //Moves cursor to the next record in the table
  end;
end;

if bfound=false then                                                            //If a match has not been found
begin
  ShowMessage('The Product ID you entered was not found, please enter a'+       //Error message
  ' valid ID');
  exit;                                                                         //Exits out of the event
end;


AssignFile(tfile, 'Changes.txt');                                               //Assign the textfile to a textfile variable
  Append(tfile);
  Writeln(tfile,'On '+DateToStr(Date)+', '+WELCOME_U.frmWelcome.sManager+       //Adds line to the textfile declaring that the signed in manager added a product
        ' deleted the product: '+sPID+#13);
  CloseFile(tfile);                                                             //Saves the changes to textfile

MANAGER_u.frmManager.OnActivate(frmManager);                                    //Runs the onactivate event wich will refresh dbgrid
ShowMessage('Product has been successfully deleted');
end;

procedure TfrmManager.pnlEditClick(Sender: TObject);
var
sPID:String;
bFound:boolean;
i:integer;
begin
sPID:=InputBox('Product ID','Please enter the ID of the product you wish to edit ',''); //Stores user's input in string variable
bfound:=false;                                                                  //False boolean variable indicates that a match for the user's input has not been found
DmShop.tblProducts.First;                                                       //Moves cursor to the first record of the database table
while (not DmShop.tblProducts.Eof) AND (bfound=false) do                        //Loop that will run to the end of the table or till a match has been found for theID the user entered
begin
  if DmShop.tblProducts['ProductID']=sPID then                                  //If a match for the Product ID has been found:
  begin
    bfound:=true;                                                               //True boolean variable indicates that a match has been found
  end
  else
  DmShop.tblProducts.Next;                                                      //Moves cursor to the next record in the table
end;

if bfound=false then                                                            //If a match has not been found
begin
  ShowMessage('The Product ID you entered was not found, please enter a'+       //Error message
  ' valid ID');
  exit;                                                                         //Exits out of the event
end;

//DmShop.tblProducts.Prior;
//Fill in all the information of unedited product
edtPName.Text:=dmshop.tblProducts['ProductName'];
EdtPDescription.Text:=dmshop.tblProducts['Description'];
for i := 0 to 5 do
  begin
    if cmbCategory.Items[i]=dmshop.tblProducts['Category'] then
    cmbCategory.ItemIndex:=i;
  end;
sedQuantity.Value:=dmshop.tblProducts['Quantity'];
sedEcoP.Value:=dmshop.tblProducts['EcoPoints'];
sedPrice.Value:=Trunc(dmshop.tblProducts['Price']);

pnlInputs.Visible:=true;                                                        //Makes the panel vissible
bEdit:=true;                                                                    //A boolean variable that indicates that the manager wants to edit an excisting product
end;

procedure TfrmManager.pnlSalesClick(Sender: TObject);
var
sFilter:string;
begin
case cmbFilterSales.ItemIndex of
  -1:sFilter:='';
  0:sFilter:='Returned';
  1:sFilter:='Cart';
  2:sFilter:='CheckedOut';
end;

dbgSales.Visible:=true;
dbgsales.DataSource:=DmShop.dsSales;                                            //Changes the dbGrid's data source to the products datasource
DmShop.qrySales.SQL.Clear;                                                      //Clears all the SQL instructions so that new instructions can be given
DmShop.qrySales.Active:=false;                                                  //Deactivates the ADOquery component
if sFilter='' then
begin
  DmShop.qrySales.SQL.Add('SELECT * FROM tblSales ORDER BY SaleID ASC');
end
else
begin
  DmShop.qrySales.SQL.Add('SELECT SaleID,Username,ProductID,TotalPrice,DateOfTransaction,Quantity,'+sFilter+' FROM tblSales WHERE '+sFilter+' = True  ORDER BY SaleID ASC ');
end;

DmShop.qrySales.Active:=true;                                                   //Activates the ADOquery component

end;

procedure TfrmManager.pnlSaveClick(Sender: TObject);
var
sCategory, sPName, sPID:string;
iPrice, iIncBy:integer;
bValid:boolean;
tfile:TextFile;
begin

if (edtPName.Text='') OR (EdtPDescription.Text='') OR (cmbCategory.ItemIndex=-1)then//If the manager did not fill in the edit boxes
begin
  ShowMessage('Please fill in all the fields.');                                //Displays appropriate message
  exit;                                                                         //Exits out of event
end;

sPName:=edtPName.Text;                                                          //Adds the text from the edit box to the variable
iPrice:=sedPrice.Value;                                                         //Adds the value in the spin edit to the variable

if bEdit=true then                                                              //If the manager wants to edit an existing product
begin
  DmShop.tblProducts.Edit;                                                      //Opens the table so there can be new products added
  DmShop.tblProducts['ProductName']:=sPName;                                    //Adds the text from variable to the correct field in table
  DmShop.tblProducts['Description']:=EdtPDescription.Text;                      //Adds the text from the edit box to the correct field in table
  DmShop.tblProducts['Category']:=cmbCategory.Text;                             //Adds the text from the edit box to the correct field in table
  DmShop.tblProducts['Quantity']:=sedQuantity.Value;                            //Adds the value in the spin edit to the correct field in table
  DmShop.tblProducts['EcoPoints']:=sedEcoP.Value;                               //Adds the value in the spin edit to the correct field in table
  DmShop.tblProducts['Price']:=iPrice;                                          //Adds the value in the variable to the correct field in table
  DmShop.tblProducts.Post;                                                      //Saves new product to the table
  AssignFile(tfile, 'Changes.txt');                                             //Assign the textfile to a textfile variable
  Append(tfile);
  Writeln(tfile,'On '+DateToStr(Date)+', '+WELCOME_U.frmWelcome.sManager+       //Adds line to the textfile declaring that the signed in manager added a product
        ' edited the product: '+DmShop.tblProducts['ProductID']+#13);
  CloseFile(tfile);                                                             //Saves the changes to textfile
  ShowMessage('Product has been successfully edited');
end
else
begin
  sPID:=Copy(sPName,1,3)+IntToStr(iPrice);                                      //Product ID exists of the first 3 characters of product name and the price of product
  DmShop.tblProducts.First;
  iIncBy:=1;                                                                    //Variable that will help to make ID valid
  while not DmShop.tblProducts.Eof do
  begin
    if DmShop.tblProducts['ProductID']=sPID then
    begin
      sPID:=Copy(sPName,1,3)+IntToStr(iPrice+iIncBy);                           //Increases the number part of ID by 1 every time there is a duplicate
      Inc(iIncBy);
    end;

    DmShop.tblProducts.Next;
  end;

  DmShop.tblProducts.Append;                                                    //Opens the table so there can be new products added
  DmShop.tblProducts['ProductID']:=sPID;                                        //Adds the text from variable to the correct field in table
  DmShop.tblProducts['ProductName']:=sPName;                                    //Adds the text from variable to the correct field in table
  DmShop.tblProducts['Description']:=EdtPDescription.Text;                      //Adds the text from the edit box to the correct field in table
  DmShop.tblProducts['Category']:=cmbCategory.Text;                             //Adds the text from the edit box to the correct field in table
  DmShop.tblProducts['Quantity']:=sedQuantity.Value;                            //Adds the value in the spin edit to the correct field in table
  DmShop.tblProducts['EcoPoints']:=sedEcoP.Value;                               //Adds the value in the spin edit to the correct field in table
  DmShop.tblProducts['Price']:=iPrice;                                          //Adds the value in the variable to the correct field in table
  DmShop.tblProducts.Post;                                                      //Saves new product to the table
  AssignFile(tfile, 'Changes.txt');                                             //Assign the textfile to a textfile variable
  Append(tfile);
  Writeln(tfile,'On '+DateToStr(Date)+', '+WELCOME_U.frmWelcome.sManager+       //Adds line to the textfile declaring that the signed in manager added a product
        ' added the product: '+sPID+#13);
  CloseFile(tfile);                                                             //Saves the changes to textfile
  ShowMessage('Product has been successfully added');
end;
MANAGER_u.frmManager.OnActivate(frmManager);                                    //Runs the onactivate event wich will refresh dbgrid
pnlInputs.Visible:=false;                                                       //Makes panel invissable
//The next lines clears all the input fields
edtPName.Text:='';
EdtPDescription.Text:='';
cmbCategory.ItemIndex:=-1;
sedQuantity.Value:=0;
sedEcoP.Value:=1;
sedPrice.Value:=1;
end;

end.
