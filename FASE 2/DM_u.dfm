object DmShop: TDmShop
  OldCreateOrder = False
  Height = 254
  Width = 283
  object conShop: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=Microsoft.ACE.OLEDB.12.0;Data Source=C:\Users\User\Desk' +
      'top\Volkies\IT\IT GR 12\GR 12 IT PAT\FASE 2\Online Shop DB.accdb' +
      ';Persist Security Info=False'
    LoginPrompt = False
    Mode = cmShareDenyNone
    Provider = 'Microsoft.ACE.OLEDB.12.0'
    Left = 8
    Top = 120
  end
  object qryProducts: TADOQuery
    Connection = conShop
    Parameters = <>
    Left = 232
    Top = 40
  end
  object dsProducts: TDataSource
    DataSet = qryProducts
    Left = 96
    Top = 40
  end
  object dsBuyer: TDataSource
    DataSet = tblBuyer
    Left = 96
    Top = 120
  end
  object tblBuyer: TADOTable
    Active = True
    Connection = conShop
    CursorType = ctStatic
    EnableBCD = False
    TableName = 'tblBuyers'
    Left = 168
    Top = 120
  end
  object dsSales: TDataSource
    AutoEdit = False
    DataSet = qrySales
    Left = 96
    Top = 192
  end
  object tblSales: TADOTable
    Active = True
    Connection = conShop
    CursorType = ctStatic
    EnableBCD = False
    TableName = 'tblSales'
    Left = 168
    Top = 192
  end
  object tblProducts: TADOTable
    Active = True
    Connection = conShop
    CursorType = ctStatic
    EnableBCD = False
    TableName = 'tblProducts'
    Left = 168
    Top = 40
  end
  object qrySales: TADOQuery
    Connection = conShop
    Parameters = <>
    Left = 232
    Top = 192
  end
end
