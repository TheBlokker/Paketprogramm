unit vCardParser;

interface

uses
  System.SysUtils, System.Classes;

type
  TKontakt = record
    Name: string;
    Telefon: string;
    Email: string;
    Strasse: string;
    Stadt: string;
    PLZ: string;
    Land: string;
  end;

  TVCardParser = class
  public
    class function LadeKontakteAusDatei(const DateiName: string): TArray<TKontakt>;
  end;

implementation

{ TVCardParser }

class function TVCardParser.LadeKontakteAusDatei(const DateiName: string): TArray<TKontakt>;
var
  Zeilen: TStringList;
  Kontakte: TArray<TKontakt>;
  i, KontaktIndex: Integer;
  Zeile: string;
  Teile: TArray<string>;
  PosDoppelpunkt: Integer;
begin
  Zeilen := TStringList.Create;
  try
    Zeilen.LoadFromFile(DateiName, TEncoding.UTF8);

    SetLength(Kontakte, 0);
    KontaktIndex := -1;

    for i := 0 to Zeilen.Count - 1 do
    begin
      Zeile := Trim(Zeilen[i]);

      if Zeile = 'BEGIN:VCARD' then
      begin
        Inc(KontaktIndex);
        SetLength(Kontakte, KontaktIndex + 1);
        FillChar(Kontakte[KontaktIndex], SizeOf(TKontakt), 0);
      end
      else if Zeile.StartsWith('FN:') then
        Kontakte[KontaktIndex].Name := Copy(Zeile, 4, MaxInt)
      else if Zeile.StartsWith('TEL') then
      begin
        PosDoppelpunkt := Pos(':', Zeile);
        if PosDoppelpunkt > 0 then
          Kontakte[KontaktIndex].Telefon := Copy(Zeile, PosDoppelpunkt + 1, MaxInt);
      end
      else if Zeile.StartsWith('EMAIL:') then
        Kontakte[KontaktIndex].Email := Copy(Zeile, 7, MaxInt)
      else if Zeile.StartsWith('ADR') then
      begin
        PosDoppelpunkt := Pos(':', Zeile);
        if PosDoppelpunkt > 0 then
        begin
          var AdressDaten := Copy(Zeile, PosDoppelpunkt + 1, MaxInt);
          Teile := AdressDaten.Split([';']);
          if Length(Teile) >= 7 then
          begin
            // ADR Struktur: Pobox;Extended;Street;City;Region;PostalCode;Country
            Kontakte[KontaktIndex].Strasse := Teile[2];
            Kontakte[KontaktIndex].Stadt := Teile[3];
            Kontakte[KontaktIndex].PLZ := Teile[5];
            Kontakte[KontaktIndex].Land := Teile[6];
          end;
        end;
      end;
    end;

    Result := Kontakte;
  finally
    Zeilen.Free;
  end;
end;

end.

