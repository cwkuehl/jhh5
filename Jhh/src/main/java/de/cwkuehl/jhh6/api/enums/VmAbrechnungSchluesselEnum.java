package de.cwkuehl.jhh6.api.enums;

/**
 * Aufzählung VmAbrechnungSchluesselEnum.
 */
public enum VmAbrechnungSchluesselEnum {
 
    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Name des Vermieters oder Mieters.
     */
    VM_NAME,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Telefonnummer des Vermieters.
     */
    VM_TELEFON,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Straße und Hausnummer des Vermieters.
     */
    VM_STRASSE,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Postleitzahl und Ort des Vermieters.
     */
    VM_ORT,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Straße und Hausnummer des Hauses.
     */
    H_STRASSE,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Postleitzahl und Ort des Hauses.
     */
    H_ORT,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Datum der Abrechnung.
     */
    H_DATUM,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Zahlungsformel bei Guthaben.
     */
    H_GUTHABEN,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Zahlungsformel bei Nachzahlung.
     */
    H_NACHZAHLUNG,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Grußformel am Ende.
     */
    H_GRUESSE,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Anlage für Abrechnung.
     */
    H_ANLAGE,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Grundsteuer.
     */
    H_GRUNDSTEUER,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Straßenreinigung, Winterdienst.
     */
    H_STRASSENREINIGUNG,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Abfallbeseitigung.
     */
    H_ABFALL,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Allgemein-Beleuchtung.
     */
    H_STROM,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Trinkwasser.
     */
    H_TRINKWASSER,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Schmutzwasser.
     */
    H_SCHMUTZWASSER,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Niederschlagswasser.
     */
    H_NIEDERSCHLAGSWASSER,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Wohngebäudeversicherung.
     */
    H_WOHNVERSICHERUNG,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Haftpflichtversicherung.
     */
    H_HAFTVERSICHERUNG,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Glasversicherung.
     */
    H_GLASVERSICHERUNG,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Dachrinnenreinigung.
     */
    H_DACHREINIGUNG,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Schornsteinfeger.
     */
    H_SCHORNSTEINFEGER,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Heckenpflege, Gartenpflege.
     */
    H_GARTEN,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Korrektur der Wohnflächen-Summe.
     */
    H_WOHNFL_KORR,

    /**
     * Vermietung-Abrechnungs-Haus-Schlüssel: Korrektur der Personenmonate-Summe.
     */
    H_PERSMON_KORR,

    /**
     * Vermietung-Abrechnungs-Wohnung-Schlüssel: Wohnfläche.
     */
    W_WOHNFLAECHE,

    /**
     * Vermietung-Abrechnungs-Mieter-Schlüssel: Anrede des Mieters.
     */
    M_ANREDE,

    /**
     * Vermietung-Abrechnungs-Mieter-Schlüssel: Name des Mieters.
     */
    M_NAME,

    /**
     * Vermietung-Abrechnungs-Mieter-Schlüssel: Straße und Hausnummer.
     */
    M_STRASSE,

    /**
     * Vermietung-Abrechnungs-Mieter-Schlüssel: Postleitzahl und Ort.
     */
    M_ORT,

    /**
     * Vermietung-Abrechnungs-Mieter-Schlüssel: Personenmonate.
     */
    M_PERSONENMONATE,

    /**
     * Vermietung-Abrechnungs-Mieter-Schlüssel: Betriebskosten-Vorauszahlung ohne Heizkosten.
     */
    M_BK_VORAUS,

    /**
     * Vermietung-Abrechnungs-Mieter-Schlüssel: Heizkosten-Vorauszahlung.
     */
    M_HK_VORAUS,

    /**
     * Vermietung-Abrechnungs-Mieter-Schlüssel: Heizkosten-Abrechnung.
     */
    M_HK_ABRECHNUNG,

    /**
     * Vermietung-Abrechnungs-Mieter-Schlüssel: Satelliten-Anlage.
     */
    M_ANTENNE,

    /**
     * Vermietung-Abrechnungs-Mieter-Schlüssel: Pflege des Vorgartens.
     */
    M_GARTEN,

    /**
     * Vermietung-Abrechnungs-Mieter-Schlüssel: Wasserstand am Anfang.
     */
    M_WASSER_ANFANG,

    /**
     * Vermietung-Abrechnungs-Mieter-Schlüssel: Wasserstand am Ende.
     */
    M_WASSER_ENDE,

    /**
     * Vermietung-Abrechnungs-Mieter-Schlüssel: Korrektur der Personenmonate-Summe.
     */
    M_PERSMON_KORR;
    public String toString() {

        if (equals(VM_NAME)) {
            return "VM_NAME";
        } else if (equals(VM_TELEFON)) {
            return "VM_TELEFON";
        } else if (equals(VM_STRASSE)) {
            return "VM_STRASSE";
        } else if (equals(VM_ORT)) {
            return "VM_ORT";
        } else if (equals(H_STRASSE)) {
            return "H_STRASSE";
        } else if (equals(H_ORT)) {
            return "H_ORT";
        } else if (equals(H_DATUM)) {
            return "H_DATUM";
        } else if (equals(H_GUTHABEN)) {
            return "H_GUTHABEN";
        } else if (equals(H_NACHZAHLUNG)) {
            return "H_NACHZAHL";
        } else if (equals(H_GRUESSE)) {
            return "H_GRUESSE";
        } else if (equals(H_ANLAGE)) {
            return "H_ANLAGE";
        } else if (equals(H_GRUNDSTEUER)) {
            return "H_GRUNDST";
        } else if (equals(H_STRASSENREINIGUNG)) {
            return "H_STRREIN";
        } else if (equals(H_ABFALL)) {
            return "H_ABFALL";
        } else if (equals(H_STROM)) {
            return "H_STROM";
        } else if (equals(H_TRINKWASSER)) {
            return "H_TRINKWAS";
        } else if (equals(H_SCHMUTZWASSER)) {
            return "H_SCHMUTZW";
        } else if (equals(H_NIEDERSCHLAGSWASSER)) {
            return "H_NIEDERW";
        } else if (equals(H_WOHNVERSICHERUNG)) {
            return "H_WOHNVERS";
        } else if (equals(H_HAFTVERSICHERUNG)) {
            return "H_HAFTVERS";
        } else if (equals(H_GLASVERSICHERUNG)) {
            return "H_GLASVERS";
        } else if (equals(H_DACHREINIGUNG)) {
            return "H_DACHREIN";
        } else if (equals(H_SCHORNSTEINFEGER)) {
            return "H_SCHORNST";
        } else if (equals(H_GARTEN)) {
            return "H_GARTEN";
        } else if (equals(H_WOHNFL_KORR)) {
            return "H_WOHNFL_K";
        } else if (equals(H_PERSMON_KORR)) {
            return "H_PERSM_K";
        } else if (equals(W_WOHNFLAECHE)) {
            return "W_WOHNFL";
        } else if (equals(M_ANREDE)) {
            return "M_ANREDE";
        } else if (equals(M_NAME)) {
            return "M_NAME";
        } else if (equals(M_STRASSE)) {
            return "M_STRASSE";
        } else if (equals(M_ORT)) {
            return "M_ORT";
        } else if (equals(M_PERSONENMONATE)) {
            return "M_PERSMON";
        } else if (equals(M_BK_VORAUS)) {
            return "M_BK_VORAU";
        } else if (equals(M_HK_VORAUS)) {
            return "M_HK_VORAU";
        } else if (equals(M_HK_ABRECHNUNG)) {
            return "M_HK_ABRE";
        } else if (equals(M_ANTENNE)) {
            return "M_ANTENNE";
        } else if (equals(M_GARTEN)) {
            return "M_GARTEN";
        } else if (equals(M_WASSER_ANFANG)) {
            return "M_WASSER_1";
        } else if (equals(M_WASSER_ENDE)) {
            return "M_WASSER_2";
        }
        return "M_PERSM_K"; // M_PERSMON_KORR

    }

    public String toString2() {

        if (equals(VM_NAME)) {
            return "Name des Vermieters";
        } else if (equals(VM_TELEFON)) {
            return "Telefonnummer des Vermieters";
        } else if (equals(VM_STRASSE)) {
            return "Straße und Hausnummer des Vermieters";
        } else if (equals(VM_ORT)) {
            return "Postleitzahl und Ort des Vermieters";
        } else if (equals(H_STRASSE)) {
            return "Straße und Hausnummer des Hauses";
        } else if (equals(H_ORT)) {
            return "Postleitzahl und Ort des Hauses";
        } else if (equals(H_DATUM)) {
            return "Datum der Abrechnung";
        } else if (equals(H_GUTHABEN)) {
            return "Zahlungsformel bei Guthaben";
        } else if (equals(H_NACHZAHLUNG)) {
            return "Zahlungsformel bei Nachzahlung";
        } else if (equals(H_GRUESSE)) {
            return "Grußformel am Ende";
        } else if (equals(H_ANLAGE)) {
            return "Anlage für Abrechnung";
        } else if (equals(H_GRUNDSTEUER)) {
            return "Grundsteuer";
        } else if (equals(H_STRASSENREINIGUNG)) {
            return "Straßenreinigung, Winterdienst";
        } else if (equals(H_ABFALL)) {
            return "Abfallbeseitigung";
        } else if (equals(H_STROM)) {
            return "Allgemein-Beleuchtung";
        } else if (equals(H_TRINKWASSER)) {
            return "Trinkwasser";
        } else if (equals(H_SCHMUTZWASSER)) {
            return "Schmutzwasser";
        } else if (equals(H_NIEDERSCHLAGSWASSER)) {
            return "Niederschlagswasser";
        } else if (equals(H_WOHNVERSICHERUNG)) {
            return "Wohngebäudeversicherung";
        } else if (equals(H_HAFTVERSICHERUNG)) {
            return "Haftpflichtversicherung";
        } else if (equals(H_GLASVERSICHERUNG)) {
            return "Glasversicherung";
        } else if (equals(H_DACHREINIGUNG)) {
            return "Dachrinnenreinigung";
        } else if (equals(H_SCHORNSTEINFEGER)) {
            return "Schornsteinfeger";
        } else if (equals(H_GARTEN)) {
            return "Heckenpflege, Gartenpflege";
        } else if (equals(H_WOHNFL_KORR)) {
            return "Korrektur der Wohnflächen-Summe";
        } else if (equals(H_PERSMON_KORR)) {
            return "Korrektur der Personenmonate-Summe";
        } else if (equals(W_WOHNFLAECHE)) {
            return "Wohnfläche";
        } else if (equals(M_ANREDE)) {
            return "Anrede des Mieters";
        } else if (equals(M_NAME)) {
            return "Name des Mieters";
        } else if (equals(M_STRASSE)) {
            return "Straße und Hausnummer";
        } else if (equals(M_ORT)) {
            return "Postleitzahl und Ort";
        } else if (equals(M_PERSONENMONATE)) {
            return "Personenmonate";
        } else if (equals(M_BK_VORAUS)) {
            return "Betriebskosten-Vorauszahlung ohne Heizkosten";
        } else if (equals(M_HK_VORAUS)) {
            return "Heizkosten-Vorauszahlung";
        } else if (equals(M_HK_ABRECHNUNG)) {
            return "Heizkosten-Abrechnung";
        } else if (equals(M_ANTENNE)) {
            return "Satelliten-Anlage";
        } else if (equals(M_GARTEN)) {
            return "Pflege des Vorgartens";
        } else if (equals(M_WASSER_ANFANG)) {
            return "Wasserstand am Anfang";
        } else if (equals(M_WASSER_ENDE)) {
            return "Wasserstand am Ende";
        }
        return "Korrektur der Personenmonate-Summe"; // M_PERSMON_KORR

    }

    public static VmAbrechnungSchluesselEnum fromValue(final String v) {
        if (v != null) {
            for (VmAbrechnungSchluesselEnum e : values()) {
                if (v.equals(e.toString())) {
                    return e;
                }
            }
        }
        throw new IllegalArgumentException("ungültige VmAbrechnungSchluesselEnum: " + v);
    }

    public String getItemValue() {
        return toString();
    }
}