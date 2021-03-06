package de.cwkuehl.jhh6.app.control.table;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import de.cwkuehl.jhh6.api.global.Global;

/**
 * Parser für Formeln im CellInhalt.
 * <p>
 * Erstellt am 05.01.2013.
 */
public class FormelParser {

    /** Interne vorkompilierte Pattern für Formel-Erkennung. */
    private static Pattern sum   = Pattern.compile("^=(sum)\\(([a-z]+)(\\d+):([a-z]+)(\\d+)\\)$",
            Pattern.CASE_INSENSITIVE);
    private static Pattern count = Pattern.compile("^=(count)\\(([a-z]+)(\\d+):([a-z]+)(\\d+)\\)$",
            Pattern.CASE_INSENSITIVE);
    private static Pattern today = Pattern.compile("^=(today)$", Pattern.CASE_INSENSITIVE);
    private static Pattern now   = Pattern.compile("^=(now)$", Pattern.CASE_INSENSITIVE);
    private static Pattern days   = Pattern.compile("^=(days)\\(([a-z]+)(\\d+)\\)$", Pattern.CASE_INSENSITIVE);

    public static void parse(CellInhalt ci) {

        String f = ci.getFormel();
        if (ci == null || Global.nes(f)) {
            return;
        }
        Matcher m = null;

        m = sum.matcher(f);
        if (m.matches()) {
            CellFormel cf = ci.getZellFormel();
            if (cf == null) {
                cf = new CellFormel();
                ci.setZellFormel(cf);
            }
            cf.setFunktion("SUM");
            cf.setSpalte1(TableModel.getColumnIndex(m.group(2)));
            cf.setZeile1(Integer.parseInt(m.group(3)) - 1);
            cf.setSpalte2(TableModel.getColumnIndex(m.group(4)));
            cf.setZeile2(Integer.parseInt(m.group(5)) - 1);
            return;
        }
        m = count.matcher(f);
        if (m.matches()) {
            CellFormel cf = ci.getZellFormel();
            if (cf == null) {
                cf = new CellFormel();
                ci.setZellFormel(cf);
            }
            cf.setFunktion("COUNT");
            cf.setSpalte1(TableModel.getColumnIndex(m.group(2)));
            cf.setZeile1(Integer.parseInt(m.group(3)) - 1);
            cf.setSpalte2(TableModel.getColumnIndex(m.group(4)));
            cf.setZeile2(Integer.parseInt(m.group(5)) - 1);
            return;
        }
        m = today.matcher(f);
        if (m.matches()) {
            CellFormel cf = ci.getZellFormel();
            if (cf == null) {
                cf = new CellFormel();
                ci.setZellFormel(cf);
            }
            cf.setFunktion("TODAY");
            return;
        }
        m = now.matcher(f);
        if (m.matches()) {
            CellFormel cf = ci.getZellFormel();
            if (cf == null) {
                cf = new CellFormel();
                ci.setZellFormel(cf);
            }
            cf.setFunktion("NOW");
            return;
        }
        m = days.matcher(f);
        if (m.matches()) {
            CellFormel cf = ci.getZellFormel();
            if (cf == null) {
                cf = new CellFormel();
                ci.setZellFormel(cf);
            }
            cf.setFunktion("DAYS");
            cf.setSpalte1(TableModel.getColumnIndex(m.group(2)));
            cf.setZeile1(Integer.parseInt(m.group(3)) - 1);
            return;
        }
        ci.setZellFormel(null);
    }

}
