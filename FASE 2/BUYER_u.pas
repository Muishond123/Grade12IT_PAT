unit BUYER_u ;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, Grids, DBGrids, StdCtrls, DB, ADODB, jpeg,
  Buttons, DM_u, WELCOME_u, Mask;

type
  TfrmBuyer = class(TForm)
    pgcBuyer: TPageControl;
    tbsStore: TTabSheet;
    tbsCart: TTabSheet;
    tbsAccount: TTabSheet;
    lblFilter: TLabel;
    cmbFilter: TComboBox;
    dbgProducts: TDBGrid;
    pnlCart: TPanel;
    lblItems: TLabel;
    pnlRemove: TPanel;
    pnlCheckout: TPanel;
    edtCardNumber: TEdit;
    lblAccount: TLabel;
    lblTotal: TLabel;
    lblInfo: TLabel;
    lblEcoPoints: TLabel;
    lblPaymentMethod: TLabel;
    cmbPaymentMethod: TComboBox;
    pnlUpdate: TPanel;
    pnlReturn: TPanel;
    pnlDelete: TPanel;
    imgBackgroundAccount: TImage;
    imgBackgroundCart: TImage;
    imgBackgroundStore: TImage;
    bbnExit: TBitBtn;
    bbnReturn: TBitBtn;
    bbnHelp: TBitBtn;
    cmbSort: TComboBox;
    pnlApply: TPanel;
    lblSort: TLabel;
    lblNewTotal: TLabel;
    dbgSales: TDBGrid;
    bbnReset: TBitBtn;
    pnlHelp: TPanel;
    redHelp: TRichEdit;
    bbnHelpCancel: TBitBtn;
    procedure bbnExitClick(Sender: TObject);
    procedure pnlApplyClick(Sender: TObject);
    procedure pnlCartClick(Sender: TObject);
    procedure bbnResetClick(Sender: TObject);
    procedure pgcBuyerChange(Sender: TObject);
    procedure pnlCheckoutClick(Sender: TObject);
    procedure pnlUpdateClick(Sender: TObject);
    procedure pnlRemoveClick(Sender: TObject);
    procedure pnlDeleteClick(Sender: TObject);
    procedure pnlReturnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure bbnReturnClick(Sender: TObject);
    procedure bbnHelpClick(Sender: TObject);
    procedure bbnHelpCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBuyer : TfrmBuyer;
implementation

{$R *.dfm}

procedure TfrmBuyer.bbnExitClick(Sender: TObject);
begin
Application.MainForm.Close;
end;

procedure TfrmBuyer.bbnHelpCancelClick(Sender: TObject);
begin
pnlHelp.Visible:=False;
end;

procedure TfrmBuyer.bbnHelpClick(Sender: TObject);
begin
pgcBuyer.ActivePage:=tbsStore;
pnlHelp.Visible:=true;
redHelp.Lines.LoadFromFile('BuyerHelp.txt');
end;

procedure TfrmBuyer.bbnResetClick(Sender: TObject);
begin
DmShop.qryProducts.SQL.Clear;                                                   //Clears all the SQL instructions so that new instructions can be given
DmShop.qryProducts.Active:=false;                                               //Deactivates the ADOquery component
DmShop.qryProducts.SQL.Add('SELECT ProductID ,ProductName, Price, EcoPoints,'+  //sql Query: Show the 5 spesified fields, filtered and sorted by the user's inputs
'Category, Description FROM tblProducts');
DmShop.qryProducts.Active:=true;                                                //Activates the ADOquery component

cmbFilter.ItemIndex:=-1;                                                        //Resets the combobox
cmbSort.ItemIndex:=-1;                                                          //Resets the combobox
end;

procedure TfrmBuyer.bbnReturnClick(Sender: TObject);
begin
frmBuyer.Hide;
frmWelcome.Show;
end;

procedure TfrmBuyer.FormActivate(Sender: TObject);
var
bFound:boolean;
begin
pgcBuyer.ActivePage:=tbsStore;                                                  //Displays the store page when the buyer form activates
dbgProducts.DataSource:=DmShop.dsProducts;                                      //Changes the dbGrid's data source to the products datasource
DmShop.qryProducts.SQL.Clear;                                                   //Clears all the SQL instructions so that new instructions can be given
DmShop.qryProducts.Active:=false;                                               //Deactivates the ADOquery component
DmShop.qryProducts.SQL.Add('SELECT ProductID,ProductName, Price, EcoPoints,'+   //SQL query is being sent to the ADOQuery component
' Category, Description FROM tblProducts');
DmShop.qryProducts.Active:=true;                                                //Activates the ADOquery component

end;

procedure TfrmBuyer.pgcBuyerChange(Sender: TObject);
var
bfound:boolean ;
sProductID:string;
iTotal, iCartItems : integer;
begin
if pgcBuyer.ActivePage=tbsCart then
begin
  if (objBuyer.GetPaymentMethod)='Card Payment' then
  cmbPaymentMethod.ItemIndex:=1
  else
  cmbPaymentMethod.ItemIndex:=2;

  edtCardNumber.Text:=objBuyer.GetPaymentDetails;
  dbgSales.DataSource:=DmShop.dsSales;                                          //Changes the dbGrid's data source to the products datasource
  DmShop.qrySales.SQL.Clear;                                                    //Clears all the SQL instructions so that new instructions can be given
  DmShop.qrySales.Active:=false;                                                //Deactivates the ADOquery component
  DmShop.qrySales.SQL.Add('SELECT tblSales.SaleID,tblProducts.ProductID, tblProducts.ProductName,'+          //Sql Query that will display the product Name, Price and Quantity units from the products in the buyer's cart
  ' SUM(tblSales.TotalPrice) AS [Total Price], SUM(tblSales.Quantity) AS [Quantity ]'
  +' FROM tblSales, tblProducts  WHERE Username ="'+ objBuyer.GetUsername +
  '" AND tblProducts.ProductID = tblSales.ProductID AND Cart = TRUE GROUP BY tblProducts.ProductID, tblProducts.ProductName, tblSales.SaleID');
  DmShop.qrySales.Active:=true;

  bfound:=false;
  iTotal:=0;                                                                    //Empty integer variable that will be used to calculate the total cost of the whole cart
  DmShop.tblBuyer.First;                                                        //Sets cursor at start of table
   while (NOT DmShop.tblBuyer.Eof) AND (bFound=false) do                        //Loop runs to end of table
  begin
    if (DmShop.tblBuyer['UserName']=objBuyer.GetUsername) AND NOT               //If the logged in user has already picked a payment method and saved his card/account details and has something in his cart
    (DmShop.tblBuyer['PaymentMethod']=NULL) AND NOT
    (DmShop.tblBuyer['Card/Account']=NULL) then
    begin
      bfound:=true;                                                             //True boolean variable indicates that the user has been found
      if DmShop.tblBuyer['PaymentMethod']='Card Payment' then
      begin
        cmbPaymentMethod.ItemIndex:=0;                                          //Changes the item index so that the saved data in the database is replicated in the combobox
        objBuyer.SetPaymentMethod('Card Payment');                              //Changes the attributes value to 'Card Payment'
      end
      else
      if DmShop.tblBuyer['PaymentMethod']='EFT' then
      begin
        cmbPaymentMethod.ItemIndex:=1;                                          //Changes the item index so that the saved data in the database is replicated in the combobox
        objBuyer.SetPaymentMethod('EFT');
      end;                                                                      //Add the total price of the record to the itotal variable
      edtCardNumber.Text:=DmShop.tblBuyer['Card/Account'];
      objBuyer.SetPaymentDetails(DmShop.tblBuyer['Card/Account']);
    end;
    DmShop.tblBuyer.Next;                                                       //Moves cursor to next record in the table
  end;
  DmShop.tblSales.first;                                                        //Sets cursor at start of table
  iCartItems:=0;
  while (NOT DmShop.tblSales.Eof) do                                            //Loop runs to end of table
  begin
    if (DmShop.tblSales['UserName']=objBuyer.GetUsername) AND                   //If the logged in user has any item in his/her cart
       (DmShop.tblSales['Cart']=TRUE) then
    begin
      Inc(iCartItems);
      iTotal:=iTotal+DmShop.tblSales['TotalPrice'] ;                            //Add the total price of the record to the itotal variable
    end;
    DmShop.tblSales.Next;                                                       //Moves cursor to next record in the table
  end;
  if iCartItems=0 then
  begin
    ShowMessage('There is no items in your cart, browse the shop for some items you might like.');
    pgcBuyer.ActivePage:=tbsStore;
  end;
  objBuyer.SetCartTotal(iTotal);                                                //Saves the variable's value as an attribute of the Buyer object
  lblTotal.Caption:='Total: '+FloatToStrF(objBuyer.GetCartTotal,ffCurrency,8,2);//Displays the object's CartTotal attribute
  lblEcoPoints.Caption:='Eco points discount: '+                               //Displays the amount of discount the buyer will get
  FloatToStrF(objBuyer.CalcDiscount,ffCurrency,8,2);
  DmShop.tblBuyer.Edit;

  objBuyer.SetEcoPoints(DmShop.tblBuyer['EcoPoints']);
  //  DmShop.tblBuyer['EcoPoints']:=objBuyer.GetEcoPoints;
  DmShop.tblBuyer.Post;
  lblNewTotal.Caption:='New total: '+FloatToStrF(objBuyer.GetCartTotal,        //Displays the object's CartTotal attribute
                                                  ffCurrency,8,2);
  bfound:=false;
  DmShop.tblBuyer.First;                                                        //Moves cursor to the first record of the table
  while (NOT DmShop.tblBuyer.Eof) AND (bFound=false) do                                            //Loop will run until the cursor is at the last record of the table
  begin
    if DmShop.tblBuyer['Username']=objBuyer.GetUsername then                    //If the username in the table is equal to the signed in user's username
    begin
      DmShop.tblBuyer.Edit;
      objBuyer.SetEcoPoints(DmShop.tblBuyer['EcoPoints']);
      DmShop.tblBuyer['EcoPoints']:=objBuyer.GetEcoPoints;                      //The amount of eco points in the table must be set equal to the amount of the eco points attribute of the object
      DmShop.tblBuyer.Post;
      bfound:=true;
    end
    else
    DmShop.tblBuyer.Next;                                                       //Moves cursor to next record of the table
  end;
end;

if pgcBuyer.ActivePage = tbsAccount then                                        //If the user changed to the Account tabsheet
begin
DmShop.tblBuyer.First;
while not(DmShop.tblBuyer.Eof) do
begin
  if DmShop.tblBuyer['Username']=objBuyer.GetUsername then
  begin
    objBuyer.SetPaymentMethod(DmShop.tblBuyer['PaymentMethod']);
    objBuyer.SetPaymentDetails(DmShop.tblBuyer['Card/Account']);
    objBuyer.SetEcoPoints(DmShop.tblBuyer['EcoPoints']);
  end;

  DmShop.tblBuyer.Next;
end;
lblInfo.Caption:=objBuyer.ToString;                                             //The laybel displays the info of the objBuyer
end;

end;

procedure TfrmBuyer.pnlApplyClick(Sender: TObject);
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

procedure TfrmBuyer.pnlCartClick(Sender: TObject);
var
iQuantity:integer;
i:integer;
sProductID : String;
bfound : boolean;
begin
sProductID:=InputBox('Product ID',                                              //The product ID variable gets the value of the product ID that the user type in the box
'Please type the product''''s ID that you wish to add to your cart','');
bfound:=false;                                                                  //False boolean variable indicates that a match for the user's input has not been found
DmShop.tblProducts.First;                                                       //Moves cursor to the first record of the database table
while (not DmShop.tblProducts.Eof) AND (bfound=false) do                        //Loop that will run to the end of the table or till a match has been found for theID the user entered
begin
  if DmShop.tblProducts['ProductID']=sProductID then                            //If a match for the Product ID has been found:
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

iQuantity:=StrToInt(inputbox('Quantity','How many products do you want to add'+ //The integer variable gets a value from the user
                             'your cart','0'));
if iQuantity<=0 then                                                            //if the user typed 0 or a negative number:
begin
  ShowMessage('Please insert a valid integer number');                          //Displays error message
  exit;                                                                         //exit out of the whole event
end;


if iQuantity<=DmShop.tblProducts['Quantity'] then                                //If there is enough products available
begin
  DmShop.tblSales.First;                                                        //Sets cursor at start of the table
  bfound:=false;                                                                //False boolean variable indicates that the buyer does not already have the product in his/her cart
  while (not DmShop.tblSales.Eof) AND (bfound=false) do                         //Loop that will run to the end of the table, or that will run untill the same product has been found in the buyer's cart
  begin
    if (DmShop.tblSales['Username']=objBuyer.GetUsername) AND                   //Checks wether the buyer already have the product in his/her cart
    (DmShop.tblSales['ProductID']=sProductID) AND
    (DmShop.tblSales['Cart']=true) then
    begin
      DmShop.tblSales.Edit;                                                     //Opens the table so that changes can be made
      DmShop.tblSales['Quantity']:=DmShop.tblSales['Quantity']+iQuantity;       //Adds the amount units of the spesific product that the buyer wants to add to his/her cart to the sales table
      DmShop.tblSales['TotalPrice']:= DmShop.tblProducts['Price']*              //Adds the chosen product's price to the sales table
                                      DmShop.tblSales['Quantity'];
      DmShop.tblSales['DateOfTransaction']:=Date ;                              //Adds the date of the day that the buyer added the product to his/her cart to the sales table
      DmShop.tblProducts.Edit;                                                  //Opens the table so that changes can be made
      DmShop.tblProducts['Quantity']:=DmShop.tblProducts['Quantity']-iQuantity; //Reduces the amount of avilable units by the amount of the units that the buyer added to his/her cart
      DmShop.tblProducts.Post;                                                  //Saves the changes to the database
      DmShop.tblSales.Post;                                                     //Saves the changes to the database
      bfound:=true;                                                             //True boolean variable indicates that the buyer already have the item in his/her cart

    end;
    DmShop.tblSales.Next;
  end;

  if bfound=false then
  begin
    DmShop.tblSales.Append;                                                       //Opens the sales table for writing
    DmShop.tblSales['Username']:= objBuyer.GetUsername ;                          //Adds the signed in buyer's username to the sales table
    DmShop.tblSales['ProductID']:= sProductID;                                    //Adds the chosen product's product ID to the sales table
    DmShop.tblSales['TotalPrice']:= DmShop.tblProducts['Price']*iQuantity ;       //Adds the chosen product's price to the sales table
    DmShop.tblSales['Quantity']:=iQuantity;                                       //Adds the amount units of the spesific product that the buyer wants to add to his/her cart to the sales table
    DmShop.tblSales['DateOfTransaction']:=Date ;                                  //Adds the date of the day that the buyer added the product to his/her cart to the sales table
    DmShop.tblSales['Cart']:=true;                                                //Boolean field indicates that the product is in a buyer's cart
    DmShop.tblProducts.Edit;                                                      //Opens the table so that there can be changes made
    DmShop.tblProducts['Quantity']:=DmShop.tblProducts['Quantity']-iQuantity;     //Reduces the amount of avilable units by the amount of the units that the buyer added to his/her cart
    DmShop.tblProducts.Post;                                                      //Saves all the changes made to the database
    DmShop.tblSales.Post;                                                         //Saves all the changes made to the database
  end;
  end
else                                                                            //If the user wants more units than what is available:
begin
showmessage('Please choose less units of the products, the are only '+          //Displays message:
IntToStr(DmShop.tblProducts['Quantity'])+' units left')   ;
exit;                                                                           //Exits out of the panel click event
end;

{ShowMessage(objBuyer.GetUsername);
dbgSales.DataSource:=DmShop.dsSales;                                            //Changes the dbGrid's data source to the products datasource
DmShop.qrySales.SQL.Clear;                                                      //Clears all the SQL instructions so that new instructions can be given
DmShop.qrySales.Active:=false;                                                  //Deactivates the ADOquery component
DmShop.qrySales.SQL.Add('SELECT tblSales.ProductID, ProductName, '+ //Sql Query that will display the product Name, Price and Quantity units from the products in the buyer's cart
'tblSales.TotalPrice, tblSales.Quantity'+
' FROM tblSales, tblProducts  WHERE Username ="'+ objBuyer.GetUsername +       //SQL query is being sent to the ADOQuery component
'" AND tblProducts.ProductID = tblSales.ProductID AND Cart = TRUE GROUP BY '+
'tblSales.ProductID');
DmShop.qrySales.Active:=true;   }                                                //Activates the ADOquery component

end;

procedure TfrmBuyer.pnlCheckoutClick(Sender: TObject);
var
sNo : string;
i, iInput, iUserCard, iEcoPoints : integer;
bvalid, bFound: boolean;
begin
if (cmbPaymentMethod.ItemIndex=-1) OR (edtCardNumber.Text='') then              //If there is no option in the combobox selected or no text in the edit box entered
begin
  showmessage('Please choose a payment method and enter your banking details'); //error message
  exit;                                                                         //Exits out of the event
end;

objBuyer.SetPaymentMethod(cmbPaymentMethod.Items[cmbPaymentMethod.ItemIndex]);  //Changes the PaymentMethod attribute of the object to the item that is currently selected in the combobox
DmShop.tblBuyer.Edit;
DmShop.tblBuyer['PaymentMethod']:=objBuyer.GetPaymentMethod;
DmShop.tblBuyer['Card/Account']:=objBuyer.GetPaymentDetails;
DmShop.tblBuyer.Post;
sNo:=edtCardNumber.Text;                                                             //Clears the string variable so that values can be added to it


if (Length(sNo) <>19) OR (sNo[1]='0') then                                      //tests wether there are 16 digits in the no., wether there are ONLY numbers in the string or wether it starts with 0
begin
  ShowMessage('The card/account number you entered is invallid. It should'+     //error message if it's an invallid no.
             ' contain 16 numbers and it may not start with a "0". There '+
             'should be 3 spaces, a space after every 4 numbers.');
  edtCardNumber.Clear;                                                          //clears the edit box for new input
  edtCardNumber.SetFocus;                                                       //Sets cursor in edit box
  exit;                                                                         //exits out of the whole event
end;

bvalid:=true;                                                                   //Boolean variable indicates that the card/account number is valid
if not (sNo[5]=' ') then                                                        //If the character in the 5th position is not a space:
bvalid:=false                                                                   //Boolean variable gets a false value to indicate that the number is invallid
else
if not (sNo[10]=' ') then                                                       //If the character in the 10th position is not a space:
bvalid:=false                                                                   //Boolean variable gets a false value to indicate that the number is invallid
else
if not (sNo[15]=' ') then                                                       //If the character in the 15th position is not a space:
bvalid:=false;                                                                  //Boolean variable gets a false value to indicate that the number is invallid

if bvalid=false then                                                            //If the password is invallid
begin
  ShowMessage('The entered card/account number is incorrect. '+                 //Displays message that explains why the number is not valid
  'There should be 3 spaces, at position 5, 10 and 15.');
  exit;                                                                         //exits out of the event
end;


bFound:=false;                                                                  //False boolean variable indicates that a match for the signed in user's username has not been found yet
DmShop.tblBuyer.First;                                                          //Moves cursor to the start of the database table
while (NOT(DmShop.tblBuyer.Eof)) AND (bFound=false) do                          //The loop will run untill the cursor has reached the end of the table or a match for the username has been found
begin
  if (DmShop.tblBuyer['Username']=objBuyer.GetUsername) AND                     //If the signed in user's record has been found and  there is no card/account number in the record
     (DmShop.tblBuyer['Card/Account']='')then
  begin
    objBuyer.SetPaymentDetails(sNo);                                            //The PaymentDetails attribute should get the value of the number typed in by the user
    dmshop.tblBuyer.Edit;
    DmShop.tblBuyer['Card/Account']:= objBuyer.GetPaymentDetails;               //The field in the buyer's reccord should get the value of the Card/Account property of the object
    dmshop.tblBuyer.post;
    bFound:=true;                                                               //True boolean variable indicates that a match has been found
  end;
  DmShop.tblBuyer.Next;
end;



iEcoPoints:=0;                                                                  //initializes the integer variable to 0
DmShop.tblSales.Close;
DmShop.tblSales.Open;
DmShop.tblSales.First;                                                          //Moves cursor to the first record of the table
while (not DmShop.tblSales.Eof) do                                              //Loop runs from start to end of the table
begin
  if (DmShop.tblSales['Username']= objBuyer.GetUsername) AND                    //If the cursor is at the signed in user's record and he/she has a product in their cart
     (DmShop.tblSales['Cart']=true) then
  begin
    DmShop.tblSales.Edit;
    DmShop.tblSales['Cart']:=false;                                             //Indicates that the product is no longer in their cart
    DmShop.tblSales['CheckedOut']:=True;                                        //Indicates that the products is now checked out
    DmShop.tblSales.post;
    DmShop.tblProducts.First;                                                   //Cursor moves to the first record of the products table
    bFound:=false;                                                              //false boolean variable indicates that the product has not been found yet
    while (NOT DmShop.tblProducts.Eof) AND (bFound=false) do                    //loop runs from first to last record in the table, or until the spesific product has been found
    begin
      if DmShop.tblProducts['ProductID']=DmShop.tblSales['ProductID'] then      //checks wether the product's productID in the product's table equals the product id in the sales table
      begin
        bFound:=true;
        iEcoPoints:=iEcoPoints+DmShop.tblProducts['EcoPoints']*                 //Increases the total eco points by the amount of eco points buyers get from buying the spesific product
                    DmShop.tblSales['Quantity'];
      end;
      DmShop.tblProducts.Next;
    end;
  end;
  DmShop.tblSales.Next;
end;

if DmShop.tblBuyer['EcoPoints']>=20 then
  begin
    DmShop.tblBuyer['EcoPoints']:=DmShop.tblBuyer['EcoPoints']-20;
  end;
ShowMessage('You got '+IntToStr(iEcoPoints)+' extra eco points!');

DmShop.tblBuyer.Edit;
DmShop.tblBuyer.First;
bFound:=false;
while (NOT DmShop.tblBuyer.Eof) AND (bFound=false) do
begin
  if DmShop.tblBuyer['Username']=objBuyer.GetUsername then
  begin
    bFound:=true;
    objBuyer.IncEcoPoints(iEcoPoints);                                          //Increases the eco points attribute of the object by the amount of ecompoints the buyer gets when they buy all the products in the cart
    DmShop.tblBuyer.edit;
    objBuyer.SetEcoPoints(DmShop.tblBuyer['EcoPoints']+iEcoPoints);
    DmShop.tblBuyer['EcoPoints']:=objBuyer.GetEcoPoints;                        //The buyers record gets updated so that it contains the total amount of eco points the buyer has
    DmShop.tblBuyer.Post;
  end;
  DmShop.tblBuyer.Next;
end;

ShowMessage('The purchase was successful! Thank you for your support! The '+    //Displays message that indicates that the purchase was successful
'product will be delivered to your home adddress in the next 3 to 5 work days');

BUYER_u.frmBuyer.pgcBuyerChange(frmBuyer);
end;

procedure TfrmBuyer.pnlDeleteClick(Sender: TObject);
var
sUsername, sPassword : string;
bfound:boolean;
begin
  sUsername:=InputBox('Username','Please enter the username of the account you'+//assigns the users username to a string variable
  ' wish to delete','');
  sPassword:=InputBox('Password','Please enter the password of the account you'+//assigns the users password to a string variable
  ' wish to delete','');

  if (sUsername=objBuyer.GetUsername) AND (sPassword=objBuyer.GetPassword) then //If the buyer entered the correct username and password
  begin
    bfound:=false;
    DmShop.tblSales.First;
    while NOT DmShop.tblSales.Eof do                                            //Loop runs through entire DB table
    begin
      if DmShop.tblSales['Username']=objBuyer.GetUsername then                  //If the signed in users record is found
      begin
        if DmShop.tblSales['Cart']=true then                                    //If the user has an item in the cart
        begin
          DmShop.tblProducts.First;
          while (not DmShop.tblProducts.Eof) AND (bfound=false) do              //Runs through products table, finds the product and increase the quantity
          begin
            if DmShop.tblProducts['ProductID']=DmShop.tblSales['ProductID'] then
            begin
              bfound:=true;
              DmShop.tblProducts.Edit;
              DmShop.tblProducts['Quantity']:=DmShop.tblProducts['Quantity']+
                                              DmShop.tblSales['Quantity'];
              DmShop.tblProducts.Post;
            end;
            DmShop.tblProducts.Next;
          end;
        DmShop.tblSales.Delete;                                                 //Deletes the buyers record in the sales tbl
        end
        else
        begin
          DmShop.tblSales.Delete;
        end;
      end;
      DmShop.tblSales.Next;
    end;
  end
  else
  begin
    ShowMessage('Your Username or password was incorrect, please try again');   //Error message if the username or password is incorrect
    exit;
  end;

bfound:=false;
DmShop.tblBuyer.First;
while (NOT DmShop.tblBuyer.Eof) AND (bfound=false) do                           //Loop runs through the buers table and delete the signed in user
begin
  if DmShop.tblBuyer['Username']=objBuyer.GetUsername then
  begin
    bfound:=true;
    DmShop.tblBuyer.Delete;
  end;
  DmShop.tblBuyer.Next;
end;

ShowMessage('You have successfully deleted your account');                      //confirmation message
frmBuyer.Hide;
frmWelcome.Show;

end;

procedure TfrmBuyer.pnlRemoveClick(Sender: TObject);
var
sProductID:string;
bFound: boolean;
iQuantity, iPrice : integer;
begin
sProductID:=InputBox('Product ID','Please enter the product''''s ProductID'+    //Buyer gets asked to enter the product ID of the product they want to remove from their cart
                     ' wich you want to remove','');

DmShop.tblSales.First;                                                          //Moves cursor to the first record of the table
bFound:=False;                                                                  //False boolean variable indicates that the product has not been found yet
while NOT(DmShop.tblSales.Eof) and (bFound=false) do                            //loop runs from first record to last one, or until the product has been found
begin
  if (DmShop.tblSales['Username']=objBuyer.GetUsername) AND                     //Checks wether the signed in user has the specific product in his/her cart
  (DmShop.tblSales['ProductID']=sProductID) AND (DmShop.tblSales['Cart']=TRUE)
  then
  begin
    bFound:=true;                                                               //True variable indicates that the product has been found
    if DmShop.tblSales['Quantity']>1 then                                       //If there are multiple units of the product
    begin
      iQuantity:=StrToInt(InputBox('Quantity','How many units of this product'+
      ' do you wish to remove from your cart?',''));                            //The buyer gets asked to enter the amount of units he wants to remove
      if (NOT(iQuantity<0))AND(NOT(iQuantity>DmShop.tblSales['Quantity'])) then //If users input is not negative or bigger than the quantity of the units in the table
      begin
        iPrice:=DmShop.tblSales['TotalPrice']/DmShop.tblSales['Quantity'];      //The price of one product gets assigned to an integer variable
        DmShop.tblSales.Edit;
        DmShop.tblSales['Quantity']:=DmShop.tblSales['Quantity']-iQuantity ;    //The quantity of the product in the sales table gets reduced by the quantity entered by the buyer
        dmshop.tblSales.Post;
        if DmShop.tblSales['Quantity']=0 then                                   //if all the units of the one product in the buyers cart is removed
        begin
          DmShop.tblSales.Delete;                                               //Deletes the whole record
        end
        else
        begin
        DmShop.tblSales.Edit;
        DmShop.tblSales['TotalPrice']:=iprice*DmShop.tblSales['Quantity'];      //The totalprice field gets the value of the original price of the product multiplied by the amount of units of that product
        DmShop.tblSales['DateOfTransaction']:=Date;                             //The date of the transaction in the table gets the value of todays date
        DmShop.tblSales.Post;                                                   //saves the changes made to the table
        DmShop.tblProducts.First;                                               //Moves cursor to the first record of the table
        bFound:=false;                                                           //False boolean variable indicates that a match for the product id has not been found yet
        while (not DmShop.tblProducts.Eof) AND (bFound=false) do                //Loop runs from first record to last record of the table, or until the product id has been found
        begin
          if DmShop.tblProducts['ProductID']=sProductID then                    //if the record's product id matches the product id entered by the buyer
          begin
            bfound:=true;                                                       //true variable indicstes that the product ID has been found
            DmShop.tblProducts.Edit;                                            //Opens the table so that there can be changed made
            DmShop.tblProducts['Quantity']:=DmShop.tblProducts['Quantity']+     //The quantity of the product in the products table increased by the amount of units the buyer wanted to remove from their cart
                                          iQuantity;
            DmShop.tblProducts.Post;                                            //Saves the changes to the table
          end;

          DmShop.tblProducts.Next;                                              //Moves to the next record of the table
        end;
        end;
        DmShop.tblSales.edit;
        DmShop.tblSales['TotalPrice']:=iprice*DmShop.tblSales['Quantity'];      //The totalprice field gets the value of the original price of the product multiplied by the amount of units of that product
        DmShop.tblSales['DateOfTransaction']:=Date;                             //The date of the transaction in the table gets the value of todays date
        DmShop.tblSales.Post;                                                   //saves the changes made to the table
        DmShop.tblProducts.First;                                               //Moves cursor to the first record of the table
        bFound:=false;                                                           //False boolean variable indicates that a match for the product id has not been found yet
        while (not DmShop.tblProducts.Eof) AND (bFound=false) do                //Loop runs from first record to last record of the table, or until the product id has been found
        begin
          if DmShop.tblProducts['ProductID']=sProductID then                    //if the record's product id matches the product id entered by the buyer
          begin
            bfound:=true;                                                       //true variable indicstes that the product ID has been found
            DmShop.tblProducts.Edit;                                            //Opens the table so that there can be changed made
            DmShop.tblProducts['Quantity']:=DmShop.tblProducts['Quantity']+     //The quantity of the product in the products table increased by the amount of units the buyer wanted to remove from their cart
                                          iQuantity;
            DmShop.tblProducts.Post;                                            //Saves the changes to the table
          end;

          DmShop.tblProducts.Next;                                              //Moves to the next record of the table
        end;

      end
      else                                                                      //If the quantity entered by the user is invalid
      begin
        ShowMessage('The quantity of units you wish to remove should be larger'+//Error message
        ' than 0 but smaller than the amount of units in your cart');
        exit;                                                                   //exits out of the event
      end;

    end;

  end;
DmShop.tblSales.next;
end;

BUYER_u.frmBuyer.pgcBuyerChange(frmBuyer);
end;

procedure TfrmBuyer.pnlReturnClick(Sender: TObject);
var
sReturn:string;
bfound:boolean;
iQuantity:integer;
begin
iQuantity:=0;
sReturn:=InputBox('What product do you wish to return','Product ID','');        //Asks user to input ID
DM_u.DmShop.tblSales.Open;                                                      //Opens table
DM_u.DmShop.tblSales.First;                                                     //Moves cursor to first table
bfound:=false;
while not (DmShop.tblSales.Eof) AND (bfound=false) do                           //loop runs through whole table
begin
  if DmShop.tblSales['Username']=objBuyer.GetUsername then                      //If cuurrent record is the user's
  begin
    if (DmShop.tblSales['ProductID']=sReturn) AND                               //If the current record is the product that the user looked for and it's checked out
       (DmShop.tblSales['CheckedOut']=True) then
    begin
      DmShop.tblSales.Edit;
      DmShop.tblSales['CheckedOut']:=False;                                     //Changes the property to false
      DmShop.tblSales['Returned']:=true;                                        //Changes the property to true
      iQuantity:=DmShop.tblSales['Quantity'];                                   //Stores the quantity of the returned product in a variable
      DmShop.tblSales.post;
      bfound:=true;
    end;

  end;
  DmShop.tblSales.Next;                                                         //Moves to next record
end;

if bfound=false then                                                            //If product isn't found
begin
  ShowMessage('Product: '+sReturn+' is not found in your sales.');              //Display appropriate message
end
else
begin
  bfound:=false;
  DM_u.DmShop.tblProducts.Open;                                                 //Opens table
  DM_u.DmShop.tblProducts.First;                                                //Moves cursor to first table
  while not (DmShop.tblProducts.Eof) AND (bfound=false) do                      //loop runs through whole table
begin
  if (DmShop.tblProducts['ProductID']=sReturn) then                             //If the product is found
  begin
    DmShop.tblProducts.Edit;
    DmShop.tblProducts['Quantity']:=iQuantity;                                  //increases quantity by the variable
    bfound:=true;
    DmShop.tblProducts.Post;                                                    //Variable indicates that product is found
  end;
  DmShop.tblProducts.Next;                                                      //Moves to next record
end;
end;

end;

procedure TfrmBuyer.pnlUpdateClick(Sender: TObject);
var
iField, i:integer;
sNewUsername, sNewPassword, sNewNo, sOldU : string;
iNewPaymentMethod: integer;
bFound, bValid: boolean;
begin
sNewUsername:='';
sNewPassword:='';
sNewNo:='';
iNewPaymentMethod:=0;
if TryStrToInt((InputBox('Update Info','What info do you want to change? '+     //If the value that the buyer entered is an integer it will be saved in the iField variable
'Type  the field you wish to change in the space below:'+
#13+'Username : 1'+#13+'Password : 2'+#13+'Payment Method : 3'+#13+
'Card/Account : 4','')),ifield) = TRUE then
begin
  if (iField<=4) AND (iField>=1) then                                           //If the number is between 1 and 4:
  begin
    case iField of
    1:sNewUsername:=InputBox('New Username','Please enter your new username',   //If the buyer entered 1, he/she will be asked to enter a new username
      '');
    2:sNewPassword:=InputBox('New Password','Please enter your new password',   //If the buyer entered 2, he/she will be asked to enter a new password
      '');

    3:if TryStrToInt(InputBox('New Username',                                   //If the buyer entered 3, he/she will be asked to enter an integer value. The value will be tested and if it is an integer value:
      'Please enter the number next to your choice of payment method.'+#13+
      'EFT : 1'+#13+'Card Payment : 2',
      ''),iNewPaymentMethod) = TRUE then
      begin
        if NOT ((iNewPaymentMethod>=1) AND (iNewPaymentMethod<=2)) then         //If the value is not an integer between 1 and 2
        begin
          ShowMessage('Invalid input.You should either choose 1 or 2.');        //Error message tells the buyer to choose a number between 1 and 2
          exit;                                                                 //exits out of the event
        end;
      end
      else
      begin                                                                     //If the user did not enter an integer value in the inputbox
        ShowMessage('Invalid input.You should enter an integer value.');        //An error message will be displayed, telling the user to please enter an integer value
        exit;
      end;
    4:sNewNo:=InputBox('New Card/Account number',                               //If the buyer entered 4, he/she will be asked to enter their bank card/account number and it will be saved in a string variable
      'Please enter your new bank card/account number','0000 0000 0000 0000');
    end;
  end
  else                                                                          //If the buyer did not enter a number between 1 and 4
  begin
    ShowMessage('Please choose a number between 1 and 4');                      //A message will be displayed asking the buyer to please enter a number between 1 and 4
    exit;                                                                       //exits out of the event
  end;
end
else                                                                            //If the buyer didn't enter an integer value:
begin
ShowMessage('Invalid input, you should enter an integer value.');               //He/she will be asked to please enter n integer value
exit;                                                                           //exits out of the event
end;

sOldU:=objBuyer.GetUsername;
if sNewUsername<>'' then
begin
DmShop.tblBuyer.First;                                                          //Set cursor at start of table
while (not(DmShop.tblBuyer.Eof))  do                                            //Loop that runs through the whole array while the typed username remains unique
  begin
      if DmShop.tblBuyer['Username']=sNewUsername then                          //Tests wether the username in the array is equal to the username that the user typed
      begin
        ShowMessage('The username you entered already exists, please enter a'+  //Error message for when the username typed by user already exists
        ' unique username.');
        exit;                                                                   //exits out of the loop
      end;
     DmShop.tblBuyer.next;
  end;
end
else
begin
  objBuyer.SetNewUsername(sNewUsername);                                        //Changes the Username attribute of the object
end;


if sNewPassword<>'' then                                                        //If the buyer entered a password
begin
  objBuyer.SetNewPassword(sNewPassword);                                        //Changes the password attribute of the object
end;

case iNewPaymentMethod of
1: objBuyer.SetPaymentMethod('EFT');                                            //If the buyer entered 1 : the PaymentMethod attribute of the object will be changed to EFT
2: objBuyer.SetPaymentMethod('Card Payment');                                   //If the buyer entered 2 : the PaymentDetails attribute of the object will be changed to Card Payment
end;

if sNewNo<>'' then                                                              //If the buyer entered a new card/account number
begin
if (Length(sNewNo)<>19) OR (sNewNo[1]='0') then//tests wether there are 16 digits in the no., wether there are ONLY numbers in the string or wether it starts with 0
begin
  ShowMessage('The card/account number you entered is invallid. It should'+     //error message if it's an invallid no.
             ' contain 16 numbers and it may not start with a "0". There '+
             'should be 3 spaces, a space after every 4 numbers.');
  exit;                                                                         //exits out of the whole event
end;
bvalid:=true;                                                                   //Boolean variable indicates that the card/account number is valid
if not (sNewNo[5]=' ') then                                                     //If the character in the 5th position is not a space:
bvalid:=false                                                                   //Boolean variable gets a false value to indicate that the number is invallid
else
if not (sNewNo[10]=' ') then                                                    //If the character in the 10th position is not a space:
bvalid:=false                                                                   //Boolean variable gets a false value to indicate that the number is invallid
else
if not (sNewNo[15]=' ') then                                                    //If the character in the 15th position is not a space:
bvalid:=false;                                                                  //Boolean variable gets a false value to indicate that the number is invallid

if bvalid=false then                                                            //If the password is invallid
begin
  ShowMessage('The entered card/account number is incorrect. '+                 //Displays message that explains why the number is not valid
  'There should be 3 spaces, at position 5, 10 and 15.');
  exit;                                                                         //exits out of the event
end;

objBuyer.SetPaymentDetails(sNewNo);                                             //Changes the PaymentDetails attribute of the object to the number entered by the buyer
end;

DmShop.tblsales.First;                                                          //Moves cursor to first record of the table
while (NOT DmShop.tblsales.Eof) do                                              //Loop runs till the cursor is at last record or the buyer's record has been found
begin
  if DmShop.tblsales['Username']=sOldU then                                     //If the buyer's record is found
  begin
    DmShop.tblsales.Edit;                                                       //Puts table in edit mode so that you can change records in DB
    DmShop.tblsales['Username']:=objBuyer.GetUsername;                          //Changes the username to the username attribute of the object
    DmShop.tblsales.Post;                                                       //Saves the changes to the DB
  end;
DmShop.tblsales.Next;                                                           //Moves cursor to next record of the table
end;

bfound := false;                                                                //false boolean variable indicates that the buyer's record has not been found yet
DmShop.tblBuyer.First;                                                          //Moves cursor to first record of the table
while (NOT DmShop.tblBuyer.Eof) AND (bFound=false) do                           //Loop runs till the cursor is at last record or the buyer's record has been found
begin
  if DmShop.tblBuyer['Username']=sOldU then                                     //If the buyer's record is found
  begin
    bfound:=true;                                                               //True variable indicates that it has been found
    DmShop.tblBuyer.Edit;                                                       //Puts table in edit mode so that you can change records in DB
    DmShop.tblBuyer['Username']:=objBuyer.GetUsername;                          //Changes the username to the username attribute of the object
    DmShop.tblBuyer['Password']:=objBuyer.GetPassword;                          //Changes the password to the password attribute of the object
    DmShop.tblBuyer['PaymentMethod']:=objBuyer.GetPaymentMethod;                //Changes the Payment method to the PaymentMethod attribute of the object
    DmShop.tblBuyer['Card/Account']:=objBuyer.GetPaymentDetails;                //Changes the Card/Account no to the PaymentDetails attribute of the object
    DmShop.tblBuyer.Post;                                                       //Saves the changes to the DB
  end;
DmShop.tblBuyer.Next;                                                           //Moves cursor to next record of the table

lblInfo.Caption:=objBuyer.ToString;
end;

end;

end.


