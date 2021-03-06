package de.cwkuehl.jhh6.api.enums;

/**
 * Aufzählung GeschlechtEnum.
 */
public enum GeschlechtEnum {

    /**
     * Geschlecht: neutrum.
     */
    NEUTRUM,

    /**
     * Geschlecht: männlich.
     */
    MANN,

    /**
     * Geschlecht: weiblich.
     */
    FRAU,

    /**
     * Geschlecht: männlich für Stammbaum.
     */
    MAENNLICH,

    /**
     * Geschlecht: weiblich für Stammbaum.
     */
    WEIBLICH;

    public String toString() {

        if (equals(NEUTRUM)) {
            return "N";
        } else if (equals(MANN)) {
            return "M";
        } else if (equals(FRAU)) {
            return "F";
        } else if (equals(MAENNLICH)) {
            return "m";
        }
        return "w"; // WEIBLICH
    }

    // public String toString2() {
    //
    // if (equals(NEUTRUM)) {
    // return "neutrum";
    // } else if (equals(MANN)) {
    // return "männlich";
    // } else if (equals(FRAU)) {
    // return "weiblich";
    // } else if (equals(MAENNLICH)) {
    // return "männlich";
    // }
    // return "weiblich"; // WEIBLICH
    // }

    public static GeschlechtEnum fromValue(final String v) {

        if (v != null) {
            for (GeschlechtEnum e : values()) {
                if (v.equals(e.toString())) {
                    return e;
                }
            }
        }
        return NEUTRUM;
        // throw new IllegalArgumentException("ungültige GeschlechtEnum: " + v);
    }

    // public String getItemValue() {
    // return toString();
    // }
}