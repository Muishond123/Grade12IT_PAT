unit WELCOME_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ToolWin, ActnMan, ActnCtrls, ActnMenus, ExtCtrls, StdCtrls, jpeg,
  Buttons, pngimage, ComCtrls, clsBuyer, Mask;

type
  TfrmWelcome = class(TForm)
    pnlCreate: TPanel;
    pnlUser: TPanel;
    edtUsername: TEdit;
    edtPassword: TEdit;
    lblUsername: TLabel;
    lblPassword: TLabel;
    pnlManager: TPanel;
    imgBackground: TImage;
    bbnExit: TBitBtn;
    imgShowPassword: TImage;
    imgHidePassword: TImage;
    procedure FormActivate(Sender: TObject);
    procedure pnlCreateClick(Sender: TObject);
    procedure imgHidePasswordMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgHidePasswordMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlUserClick(Sender: TObject);
    procedure pnlManagerClick(Sender: TObject);
    procedure bbnExitClick(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
    sManager:string;
  end;

var
  frmWelcome: TfrmWelcome;
  objBuyer : TBuyer ;
 

implementation
uses
BUYER_u, MANAGER_u, DM_u;
var
 arrManager : array [1..3] of string = ('HanreD','Willempie','AdriaanVDM') ;
  arrMPassword : array [1..3] of string =('B@@svdPlaas2005','W!11em007','A3@@n');
  arrUsername : array [1..25] of string ;
  arrUPassword : array [1..25] of string ;
  arrEcoPoints : array [1..25] of integer ;
  iNoUsers:integer;

{$R *.dfm}

procedure TfrmWelcome.bbnExitClick(Sender: TObject);
begin
Application.MainForm.Close;
end;

procedure TfrmWelcome.FormActivate(Sender: TObject);
var
i:integer;
begin
ShowMessage('Die username en password wat alreeds ingevul is kan juffrou gebruik om as n user in te teken, om as n manager in te teken kan juffrou : HanreD (username) en B@@svdPlaas2005(Password) gebruik');
edtPassword.PasswordChar:='*';                                                  //Turns all the characters in the password edit box to "*".
imgShowPassword.Visible:=false;                                                 //Hides the showpassword icon.

iNoUsers:=0;                                                                    //Variable stores the ammount of users registered
with DM_u.dmshop do
begin
  tblSales.Active:=true;
  tblBuyer.Active:=true;
  tblSales.Open;                                                                //Opens the sales table for later use
  tblBuyer.Open;                                                                //Opens the database table to read and write.
  tblBuyer.First;                                                               //Sets cursor at start of table
  while (not (tblBuyer.Eof)) and (iNoUsers<=25) do                              //Loop will run from first to last record of the table or untilthe array is full
  begin
    Inc(iNoUsers);
    arrUsername[iNoUsers]:=tblBuyer['Username'];                                //Loads the username from the table into an array
    arrUPassword[iNoUsers]:=tblBuyer['Password'];                               //Loads the password from the table into another array
    if tblBuyer['EcoPoints']=Null then
    begin
    arrEcoPoints[iNoUsers]:=0
    end
    else
    begin
    arrEcoPoints[iNoUsers]:=tblBuyer['EcoPoints'];                              //Loads the EcoPoints from the table into an EcoPoints array
    end;
    if iNoUsers=25 then                                                         //If there are 20 users in the dataase table:
    begin
    ShowMessage('The programmer should update the Username and Password arrays');//Display message that a programmer should increase the size of the arrays, because the arrays can only store 25 users' info
    exit;                                                                       //Exits out of the whole event
    end;
    tblBuyer.Next;                                                              //Cursor moves to the next record of the table
  end;
end;

end;

procedure TfrmWelcome.imgHidePasswordMouseDown(Sender: TObject;                 //When user holds the picture down:
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
imgShowPassword.Visible:=true;                                                  //Shows the "show password" icon.
imgHidePassword.Visible:=false;                                                 //Hides the "hide password" icon.
edtPassword.PasswordChar:=#0;                                                   //Shows the text in the edit box.
end;

procedure TfrmWelcome.imgHidePasswordMouseUp(Sender: TObject;                   //When user stops holding picture down:
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
imgShowPassword.Visible:=false;                                                 //Hides the "show password" icon.
imgHidePassword.Visible:=true;                                                  //Shows the "hide password" icon.
edtPassword.PasswordChar:='*';                                                  //Turns all the characters in the password edit box to "*".
end;

procedure TfrmWelcome.pnlCreateClick(Sender: TObject);
var
iEmpty, iCount:integer;
bExists:boolean;
begin

if (edtUsername.Text='') or (edtPassword.Text='') then                          //Checks wether edit boxes is empty or not
begin
  ShowMessage('Please fill in both your username and password before trying to'+
  ' create a new account');                                                     //Error message for when the edit boxes is empty
  exit;                                                                         //Exits out of the panelcreateclick event so that no further processing can be done
end;

iCount:=1;
bExists:=false;                                                                 //Boolean variable wich will be used to check wether a spesific username already exists
while (bExists=false) and (iCount<=iNoUsers) do                                 //Loop that runs through the whole array while the typed username remains unique
  begin
      if arrUsername[iCount]=edtUsername.Text then                              //Tests wether the username in the array is equal to the username that the user typed
      begin
        ShowMessage('The username you typed in already exists, if you want to'+
        ' create a new account you should choose a unique username.');          //Error message for when the username typed by user already exists
        edtUsername.Clear;                                                      //Clears the username edit box
        edtPassword.Clear;                                                      //Clears the password edit box
        bExists:=true;                                                          //boolean variable becomes true thus the loop will end
      end;
      Inc(iCount);                                                              //increases the counter variable by 1
  end;

  if bExists = false then
  begin
    Inc(iNoUsers);
    if iNoUsers<=25 then
    begin                                                                       //Increases the number of users, because a user is being added
      arrUsername[iNoUsers]:= edtUsername.Text;                                 //The username typed by the user will be added to the array in an empty field
      arrUPassword[iNoUsers]:= edtPassword.Text;                                //The password typed by the user will be added to the array in an empty field
      ShowMessage('You have successfully created an account as '                //Confirmation message, confirms that the account has been created.
      +edtUsername.Text);

      with DM_u.DmShop do
      begin
        tblBuyer.Append;                                                        //Opens the table for wrighting
        tblBuyer['Username']:=arrUsername[iNoUsers];                            //Ads the new username to the database
        tblBuyer['Password']:=arrUPassword[iNoUsers];                           //Adds new password to the database
        tblBuyer['EcoPoints']:=0;
        tblBuyer['PaymentMethod']:='';
        tblBuyer['Card/Account']:='';
        tblBuyer.Post;                                                          //Saves the changes made to the database
      end;
    objBuyer:=TBuyer.Create(arrUsername[iNoUsers], arrUPassword[iNoUsers], 0);
    frmWelcome.Hide;
    frmBuyer.Show;
    end
    else
    ShowMessage('The programmer should increase the ammount of users in the'+
    'users array');


  end;


end;


procedure TfrmWelcome.pnlManagerClick(Sender: TObject);
var
i, iCount:integer;
bFound:boolean;
begin

if (edtUsername.Text='') or (edtPassword.Text='') then                          //Checks wether edit boxes is empty or not
begin
  ShowMessage('Please fill in both your username and password before trying to'+
  ' sign in as a manager');                                                     //Error message for when the edit boxes is empty
  exit;                                                                         //Exits out of the panelcreateclick event so that no further processing can be done
end;

iCount:=1;
bfound:=false;
while (bfound=false) and (icount<=3) do
begin
  if edtUsername.Text = arrManager[iCount] then                                 //If the username in the edit box equals the username in the array at position iCount
      begin
        if edtPassword.Text = arrMPassword[iCount] then                         //If the password in the edit box equals the password in the array at position iCount
        begin
          sManager:=arrManager[iCount];
          ShowMessage('Successfully logged in as '+arrManager[iCount]);         //confirmation message that the user has successfully logged in
          bFound:=true;                                                         //Changes the value of the boolean variable to true so that the loop will be stopped
          frmWelcome.Hide;                                                      //the current form wil be hidden
          frmManager.show;                                                      //the form of the buyer will be shown
        end
        else                                                                    //If the password in the edit box is not equal to the password in the password array at position iCount:
        begin
          ShowMessage('Your password was incorrect, please try again.');        //An error message to tell user his/her password does not match their username's saved password.
          edtPassword.Text:='';
          exit;                                                                 //Exit out of the loops so that processing can be stopped immediately
        end;
      end;
  Inc(icount);                                                                  //Increases the icount variable by 1, so that the loop will stop when all the usernames in the array has been tested
end;

if bfound=false then                                                            //if the username has not been found:
  ShowMessage('The username you typed does not exist as a manager'''+'s'+
  ' username, please check your spelling or try signing in as a buyer.');       //Display this message


end;

procedure TfrmWelcome.pnlUserClick(Sender: TObject);
var
iCount:integer;
bFound:boolean;
sUsername, sPassword:string;
iEcoPoints:integer;
begin

if (edtUsername.Text='') or (edtPassword.Text='') then                          //Checks wether edit boxes is empty or not
begin
  ShowMessage('Please fill in both your username and password before trying to'+
  ' sign in as a user');                                                        //Error message for when the edit boxes is empty
  exit;                                                                         //Exits out of the panelcreateclick event so that no further processing can be done
end;

iCount:=1;
bfound:=false;
while (bfound=false) and (icount<=iNoUsers) do
begin
  if edtUsername.Text = arrUsername[iCount] then                                //If the username in the edit box equals the username in the array at position iCount
      begin
        if edtPassword.Text = arrUPassword[iCount] then                         //If the password in the edit box equals the password in the array at position iCount
        begin
          ShowMessage('Successfully logged in as '+arrUsername[iCount]);        //confirmation message that the user has successfully logged in
          bFound:=true;                                                         //Changes the value of the boolean variable to true so that the loop will be stopped
          sUsername:=arrUsername[iCount];                                       //The Username variable gets the value of the signed in user's username
          sPassword:=arrUPassword[iCount];                                      //The Password variable gets the value of the signed in user's password
          iEcoPoints:=arrEcoPoints[iCount];                                     //The EcoPoints variable gets the value of the signed in user's total amount of eco points
          objBuyer:=TBuyer.Create(sUsername, sPassword, iEcopoints);            //Initialize the Buyer Object
          frmWelcome.Hide;                                                      //the current form wil be hidden
          frmbuyer.show;                                                        //the form of the buyer will be shown
        end
        else                                                                    //If the password in the edit box is not equal to the password in the password array at position iCount:
        begin
          ShowMessage('Your password was incorrect, please try again.');        //An error message to tell user his/her password does not match their username's saved password.
          edtPassword.Text:='';
          exit;                                                                 //Exit out of the loops so that processing can be stopped immediately
        end;
      end;
  Inc(icount);                                                                  //Increases the icount variable by 1, so that the loop will stop when all the usernames in the array has been tested
end;

if bfound=false then                                                            //if the username has not been found:
  ShowMessage('The username you typed does not exist, check your spelling or '+ //Display this message
  'create a new account by clicking on the "Create account" button');


end;

end.
