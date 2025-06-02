unit Worker;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.IOUtils, Math, Generics.Collections;

type
  TSendungInfo = class
  public
    Anbieter: string;
    ProduktName: string;
    Typ: string;
    Preis: Double;
  end;

  TWorker = class
  public
    function FindePassendeSendungen(L, B, H, Gewicht: Double; Express, Einschreiben: Boolean): TList<TSendungInfo>;
    procedure PrüfeSendung(L, B, H, Gewicht: Double; Express, Einschreiben: Boolean); // Beibehalten für die Konsolenausgabe (optional)
  end;

implementation

function TWorker.FindePassendeSendungen(L, B, H, Gewicht: Double; Express, Einschreiben: Boolean): TList<TSendungInfo>;
var
  JsonStr: string;
  Json: TJSONObject;
  Sendungen: TJSONArray;
  Sendung, Maße, Optionen: TJSONObject;
  I: Integer;
  LängeMin, LängeMax, BreiteMin, BreiteMax, HöheMax, MaxGewicht, SummeLaengsteKuerzeste : Double;
  Anbieter, ProduktName: string;
  Preis: Double;
  Seiten: TArray<Double>;
  MinSeite, MaxSeite: Double;
  SendungInfo: TSendungInfo;
begin
  Result := TList<TSendungInfo>.Create;
  JsonStr := TFile.ReadAllText('anbieter.json');
  Json := TJSONObject.ParseJSONValue(JsonStr) as TJSONObject;
  Sendungen := Json.GetValue<TJSONArray>('sendungen');

  for I := 0 to Sendungen.Count - 1 do
  begin
    Sendung := Sendungen.Items[I] as TJSONObject;
    Anbieter := Sendung.GetValue<string>('anbieter');
    ProduktName := Sendung.GetValue<string>('name');
    Maße := Sendung.GetValue<TJSONObject>('mass_cm');
    Optionen := Sendung.GetValue<TJSONObject>('optionen');

    LängeMin := Maße.GetValue<Double>('laenge_min');
    LängeMax := Maße.GetValue<Double>('laenge_max');
    BreiteMin := Maße.GetValue<Double>('breite_min');
    BreiteMax := Maße.GetValue<Double>('breite_max');
    HöheMax := Maße.GetValue<Double>('hoehe_max');
    MaxGewicht := Sendung.GetValue<Double>('max_gewicht_g');
    Preis := Sendung.GetValue<Double>('preis_euro');

    // Überprüfung auf FindValue anstatt von einfachen reinlesen.
    if Express and (Optionen.FindValue('express') <> nil) then
      Preis := Preis + Optionen.GetValue<Double>('express');


    // Wenn Anbieter Hermes/GLS ist, berücksichtige nur die längste und kürzeste Seite
    if (Anbieter = 'Hermes') or (Anbieter = 'GLS') or (Anbieter = 'DPD') then
    begin
      // Bestimme die größte und kleinste Seite
      Seiten := [L, B, H];
      MinSeite := Min(Min(Seiten[0], Seiten[1]), Seiten[2]);
      MaxSeite := Max(Max(Seiten[0], Seiten[1]), Seiten[2]);
      SummeLaengsteKuerzeste:= MinSeite + MaxSeite;

      // Vergleiche mit den erlaubten Maßen
      if (SummeLaengsteKuerzeste <= Sendung.GetValue<Double>('max_summe_laengste_kuerzeste')) and (Gewicht <= MaxGewicht) then
      begin
        SendungInfo := TSendungInfo.Create;
        SendungInfo.Anbieter := Anbieter;
        SendungInfo.ProduktName := ProduktName;
        SendungInfo.Preis := Preis;
        Result.Add(SendungInfo);
      end;
    end
    else
    begin
      // Für alle anderen Anbieter bleibt die Standardberechnung
      if (L >= LängeMin) and (L <= LängeMax) and
          (B >= BreiteMin) and (B <= BreiteMax) and
          (H <= HöheMax) and
          (Gewicht <= MaxGewicht) then
      begin
        SendungInfo := TSendungInfo.Create;
        SendungInfo.Anbieter := Anbieter;
        SendungInfo.ProduktName := ProduktName;
        SendungInfo.Preis := Preis;
        Result.Add(SendungInfo);
      end;
    end;
  end;

  Json.Free;
end;

procedure TWorker.PrüfeSendung(L, B, H, Gewicht: Double; Express, Einschreiben: Boolean);
var
  PassendeSendungen: TList<TSendungInfo>;
  SendungInfo: TSendungInfo;
  I: Integer;
begin
  PassendeSendungen := FindePassendeSendungen(L, B, H, Gewicht, Express, Einschreiben);
  try
    for I := 0 to PassendeSendungen.Count - 1 do
    begin
      SendungInfo := PassendeSendungen[I];
      Writeln('✅ Anbieter: ', SendungInfo.Anbieter);
      Writeln('📦 Produkt: ', SendungInfo.ProduktName);
      Writeln('📦 Typ: ', SendungInfo.Typ);
      Writeln('💶 Preis: ', FormatFloat('0.00', SendungInfo.Preis), ' €');
      Writeln('---');
    end;
  finally
    PassendeSendungen.Free;
  end;
end;

end.
