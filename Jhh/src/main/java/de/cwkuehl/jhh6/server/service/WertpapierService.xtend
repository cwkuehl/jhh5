package de.cwkuehl.jhh6.server.service

import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.dto.SoKurse
import de.cwkuehl.jhh6.api.dto.WpAnlage
import de.cwkuehl.jhh6.api.dto.WpAnlageKey
import de.cwkuehl.jhh6.api.dto.WpAnlageLang
import de.cwkuehl.jhh6.api.dto.WpBuchung
import de.cwkuehl.jhh6.api.dto.WpBuchungKey
import de.cwkuehl.jhh6.api.dto.WpBuchungLang
import de.cwkuehl.jhh6.api.dto.WpKonfiguration
import de.cwkuehl.jhh6.api.dto.WpKonfigurationKey
import de.cwkuehl.jhh6.api.dto.WpKonfigurationLang
import de.cwkuehl.jhh6.api.dto.WpStand
import de.cwkuehl.jhh6.api.dto.WpStandKey
import de.cwkuehl.jhh6.api.dto.WpStandLang
import de.cwkuehl.jhh6.api.dto.WpWertpapier
import de.cwkuehl.jhh6.api.dto.WpWertpapierKey
import de.cwkuehl.jhh6.api.dto.WpWertpapierLang
import de.cwkuehl.jhh6.api.enums.WpStatusEnum
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.generator.RepositoryRef
import de.cwkuehl.jhh6.generator.Service
import de.cwkuehl.jhh6.generator.Transaction
import de.cwkuehl.jhh6.server.fop.dto.PnfChart
import de.cwkuehl.jhh6.server.fop.dto.PnfPattern
import de.cwkuehl.jhh6.server.rep.impl.MaParameterRep
import de.cwkuehl.jhh6.server.rep.impl.WpAnlageRep
import de.cwkuehl.jhh6.server.rep.impl.WpBuchungRep
import de.cwkuehl.jhh6.server.rep.impl.WpKonfigurationRep
import de.cwkuehl.jhh6.server.rep.impl.WpStandRep
import de.cwkuehl.jhh6.server.rep.impl.WpWertpapierRep
import java.awt.BasicStroke
import java.awt.Color
import java.awt.Font
import java.awt.Graphics2D
import java.awt.geom.Ellipse2D
import java.awt.geom.Line2D
import java.io.BufferedReader
import java.io.DataOutputStream
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.ZoneId
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter
import java.util.ArrayList
import java.util.Collections
import java.util.HashMap
import java.util.List
import java.util.Locale
import javax.net.ssl.HttpsURLConnection
import org.json.JSONObject

@Service
class WertpapierService {

	@RepositoryRef MaParameterRep parameterRep
	@RepositoryRef WpAnlageRep anlageRep
	@RepositoryRef WpBuchungRep buchungRep
	@RepositoryRef WpKonfigurationRep konfigurationRep
	@RepositoryRef WpStandRep standRep
	@RepositoryRef WpWertpapierRep wertpapierRep

	@Transaction(false)
	override ServiceErgebnis<List<WpKonfigurationLang>> getKonfigurationListe(ServiceDaten daten,
		boolean zusammengesetzt, String status) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<WpKonfigurationLang>>(null)
		var liste = konfigurationRep.getKonfigurationLangListe(daten, null, status)
		for (WpKonfigurationLang e : liste) {
			fillKonfiguration(e)
			if(zusammengesetzt) {
				e.bezeichnung = PnfChart.getBezeichnung(e.bezeichnung, e.box, e.skala, e.umkehr, e.methode, e.relativ,
					e.dauer, null, 0, 0)
			}
		}
		r.ergebnis = liste
		return r
	}

	def private WpKonfigurationLang fillKonfiguration(WpKonfigurationLang e) {

		if(e !== null) {
			var array = if(Global.nes(e.parameter)) null else e.parameter.split(";")
			var l = Global.arrayLaenge(array)
			if(l >= 4) {
				e.box = Global.strDbl(array.get(0))
				e.prozentual = Global.objBool(array.get(1))
				e.skala = if(e.prozentual) 1 else 2
				e.umkehr = Global.strInt(array.get(2))
				e.methode = Global.strInt(array.get(3))
			}
			if(l >= 6) {
				e.dauer = Global.strInt(array.get(4))
				e.relativ = Global.objBool(array.get(5))
			}
			if(l >= 7) {
				e.skala = Global.strInt(array.get(6))
			}
			if(e.dauer <= 0) {
				e.dauer = 182
			}
		}
		return e
	}

	@Transaction(false)
	override ServiceErgebnis<WpKonfigurationLang> getKonfigurationLang(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<WpKonfigurationLang>(null)
		var l = konfigurationRep.getKonfigurationLangListe(daten, uid, null)
		if(l.size > 0) {
			r.ergebnis = fillKonfiguration(l.get(0))
		}
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<WpKonfiguration> insertUpdateKonfiguration(ServiceDaten daten, String uid, String bez,
		double box, boolean proz, int umkehr, int methode, int dauer, boolean relativ, int skala, String status, //
		String notiz) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		if(!Global.nes(uid) && Global.nes(bez)) {
			throw new MeldungException("Die Bezeichnung darf nicht leer sein.")
		}
		if(!Global.nes(uid) && Global.nes(status)) {
			throw new MeldungException("Der Status darf nicht leer sein.")
		}
		if(Global.compDouble4(box, 0) <= 0) {
			throw new MeldungException("Die Boxgröße muss größer 0 sein.")
		}
		if(umkehr <= 0) {
			throw new MeldungException("Die Umkehr muss größer 0 sein.")
		}
		if(!Global.in(methode, 1, 5)) {
			throw new MeldungException("Falsche Methode.")
		}
		if(dauer <= 10) {
			throw new MeldungException("Die Dauer muss größer 10 sein.")
		}
		if(!Global.in(methode, 0, 2)) {
			throw new MeldungException("Falsche Skala.")
		}
		var sb = new StringBuilder
		sb.append(box)
		sb.append(";").append(proz)
		sb.append(";").append(umkehr)
		sb.append(";").append(methode)
		sb.append(";").append(dauer)
		sb.append(";").append(relativ)
		sb.append(";").append(skala)
		var e = konfigurationRep.iuWpKonfiguration(daten, null, uid, bez, sb.toString, status, notiz, null, null, null,
			null)
		var r = new ServiceErgebnis<WpKonfiguration>(e)
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<Void> deleteKonfiguration(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		konfigurationRep.delete(daten, new WpKonfigurationKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<MaEinstellung>> getWertpapierStatusListe(ServiceDaten daten) {

		var liste = new ArrayList<MaEinstellung>
		for (WpStatusEnum p : WpStatusEnum.values) {
			var e = new MaEinstellung
			e.mandantNr = daten.mandantNr
			e.schluessel = p.toString
			e.wert = p.toString2
			liste.add(e)
		}
		var r = new ServiceErgebnis<List<MaEinstellung>>(liste)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<WpWertpapierLang>> getWertpapierListe(ServiceDaten daten, boolean zusammengesetzt,
		String bez, String muster, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<WpWertpapierLang>>(null)
		var liste = getWertpapierListeIntern(daten, zusammengesetzt, bez, muster, uid, null, null, false, false, null,
			null)
		r.ergebnis = liste
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<List<WpWertpapierLang>> bewerteteWertpapierListe(ServiceDaten daten,
		boolean zusammengesetzt, String bez, String muster, String uid, LocalDate bewertungsdatum, String kuid,
		StringBuffer status, StringBuffer abbruch) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<WpWertpapierLang>>(null)
		var liste = getWertpapierListeIntern(daten, zusammengesetzt, bez, muster, uid, bewertungsdatum, kuid, true,
			true, status, abbruch)
		r.ergebnis = liste
		return r
	}

	def private List<WpWertpapierLang> getWertpapierListeIntern(ServiceDaten daten, boolean zusammengesetzt, String bez,
		String muster, String uid, LocalDate bewertungsdatum, String kuid, boolean nuraktiv, boolean speichern,
		StringBuffer status, StringBuffer abbruch) {

		var WpKonfigurationLang k = null
		if(!Global.nes(kuid)) {
			var l = konfigurationRep.getKonfigurationLangListe(daten, kuid, null)
			if(Global.listLaenge(l) > 0) {
				k = fillKonfiguration(l.get(0))
				k.bezeichnung = PnfChart.getBezeichnung(k.bezeichnung, 0, k.skala, k.umkehr, k.methode, k.relativ,
					k.dauer, null, 0, 0)
			}
		}
		var liste = wertpapierRep.getWertpapierLangListe(daten, bez, muster, null, uid, null, nuraktiv)
		for (WpWertpapierLang e : liste) {
			fillWertpapier(e, k)
			if(zusammengesetzt && !Global.nes(e.relationBezeichnung)) {
				e.bezeichnung = Global.anhaengen(new StringBuffer(e.bezeichnung), " (", e.relationBezeichnung, ")").
					toString
			}
		}
		if(bewertungsdatum !== null) {
			val bis = bewertungsdatum
			val von = bis.minusDays(if(k === null) 182 else k.dauer)
			val l = liste.size
			for (var i = 0; i < l && abbruch.length <= 0; i++) {
				val a = liste.get(i)
				status.length = 0
				status.
					append('''(«i+1» von «l») Berechnung von «a.bezeichnung» am «bis» «if (k === null) "ohne Konfiguration" else k.bezeichnung»''')
				berechneBewertung(daten, von, bis, a, k, speichern)
			}
		}
		return liste
	}

	def private WpWertpapierLang fillWertpapier(WpWertpapierLang e, WpKonfigurationLang k) {

		if(e !== null) {
			var array = if(Global.nes(e.parameter)) null else e.parameter.split(";")
			var l = Global.arrayLaenge(array)
			e.aktuellerkurs = if(l <= 0) "" else array.get(0)
			// Zielkurs wird manuell erfasst.
			e.signalkurs1 = if(l <= 1)
				Double.POSITIVE_INFINITY
			else if(Global.compDouble4(Global.strDbl(array.get(1)), 0) == 0)
				Double.NaN
			else
				Global.strDbl(array.get(1))
			e.signalkurs2 = if(l <= 2) "" else array.get(2)
			e.setStopkurs = if(l <= 3) "" else array.get(3)
			e.muster = if(l <= 4) "" else array.get(4)
			e.sortierung = if(l <= 5) "" else array.get(5)
			e.bewertung = if(l <= 6) "" else array.get(6)
			e.bewertung1 = if(l <= 7) "" else array.get(7)
			e.bewertung2 = if(l <= 8) "" else array.get(8)
			e.bewertung3 = if(l <= 9) "" else array.get(9)
			e.bewertung4 = if(l <= 10) "" else array.get(10)
			e.bewertung5 = if(l <= 11) "" else array.get(11)
			e.trend1 = if(l <= 12) "" else array.get(12)
			e.trend2 = if(l <= 13) "" else array.get(13)
			e.trend3 = if(l <= 14) "" else array.get(14)
			e.trend4 = if(l <= 15) "" else array.get(15)
			e.trend5 = if(l <= 16) "" else array.get(16)
			e.trend = if(l <= 17) "" else array.get(17)
			e.kursdatum = if(l <= 18) "" else array.get(18)
			e.xo = if(l <= 19) "" else array.get(19)
			e.signalbew = if(l <= 20) "" else array.get(20)
			e.signaldatum = if(l <= 21) "" else array.get(21)
			e.signalbez = if(l <= 22) "" else array.get(22)
			e.index1 = if(l <= 23) "" else array.get(23)
			e.index2 = if(l <= 24) "" else array.get(24)
			e.index3 = if(l <= 25) "" else array.get(25)
			e.index4 = if(l <= 26) "" else array.get(26)
			e.schnitt200 = if(l <= 27) "" else array.get(27)
			e.konfiguration = if(k === null) "ohne" else k.bezeichnung
		}
		return e
	}

	def private void berechneBewertung(ServiceDaten daten, LocalDate dvon, LocalDate dbis, WpWertpapierLang wp,
		WpKonfigurationLang k, boolean speichern) {

		wp.bewertung = "00 ohne"
		wp.bewertung1 = ""
		wp.bewertung2 = ""
		wp.bewertung3 = ""
		wp.bewertung4 = ""
		wp.bewertung5 = ""
		wp.muster = ""
		wp.stopkurs = ""
		// Zielkurs (Signalkur1) wird manuell erfasst.
		wp.signalkurs2 = ""
		wp.trend1 = ""
		wp.trend2 = ""
		wp.trend3 = ""
		wp.trend4 = ""
		wp.trend5 = ""
		wp.trend = ""
		wp.kursdatum = ""
		wp.xo = ""
		wp.signalbew = ""
		wp.signaldatum = ""
		wp.signalbez = ""
		// wp.konfiguration = if (k === null) "ohne" else k.bezeichnung
		wp.index1 = ""
		wp.index2 = ""
		wp.index3 = ""
		wp.index4 = ""
		wp.schnitt200 = ""
		if(wp === null || !"1".equals(wp.status)) {
			return
		}
		try {
			var liste = holeKurseIntern(daten, dvon, dbis, wp.kuerzel,
				if(k !== null && k.relativ) wp.relationKuerzel else null)
			var kursdatum = if(liste.size > 0) liste.get(liste.size - 1).datum.toLocalDate else dbis
			var signalbew = 0
			var signaldatum = dvon
			var String signalbez = null
			var double[] a = #[0.5, 1, 2, 3, 5]
			var String[] t = #[null, null, null, null, null]
			var int[] bew = #[0, 0, 0, 0, 0]
			for (var i = 0; i < a.length; i++) {
				var c = new PnfChart
				// c.setUmkehr(box)
				c.box = a.get(i)
				c.bezeichnung = wp.bezeichnung
				c.ziel = wp.signalkurs1
				c.stop = Global.strDbl(wp.stopkurs)
				if(k === null) {
					c.methode = 4
					c.skala = 2 // dynamisch
					c.umkehr = 3
					c.relativ = false
				} else {
					c.methode = k.methode
					c.skala = k.skala
					c.umkehr = k.umkehr
					c.relativ = k.relativ
				}
				c.addKurse(liste)
				// letztes Signal
				var p = c.pattern.reduce[prev, cur|cur] // .orElse(null)
				// nur bei letzter Säule, Signal am gleichen Tag
				if(p !== null) {
					if(p.xpos >= c.saeulen.size - 1 && p.datum.toLocalDate.equals(kursdatum)) {
						bew.set(i, p.signal)
						if(Global.nes(wp.muster)) {
							wp.muster = PnfPattern.getBezeichnung(p.muster)
						}
					}
					if(p.datum.toLocalDate.isAfter(signaldatum) ||
						(p.datum.toLocalDate.equals(signaldatum) && Math.abs(p.signal) > Math.abs(signalbew))) {
						signalbew = p.signal
						signaldatum = p.datum.toLocalDate
						signalbez = PnfPattern.getBezeichnung(p.muster)
					}
				}
				if(c.saeulen.size > 0 && c.saeulen.get(c.saeulen.size - 1).datum.toLocalDate.equals(kursdatum)) {
					wp.xo = if(c.saeulen.get(c.saeulen.size - 1).
						isO) '''xo «Global.dblStr(c.box)»''' else '''ox «Global.dblStr(c.box)»'''
				}
				if(i == 0) {
					wp.aktuellerkurs = Global.dblStr2l(c.kurs)
					if(Global.compDouble4(c.stop, 0) > 0) {
						wp.stopkurs = Global.dblStr2l(c.stop)
						wp.signalkurs2 = Global.dblStr4l(c.kurs / c.stop)
					}
				}
				var tr = c.trend
				// t.set(i, if(tr > 0) "+1" else if(tr < 0) "-1" else "0")
				t.set(i, if(tr == 2)
					"+2"
				else if(tr == 1)
					"+1"
				else if(tr == 0.5)
					"+0,5"
				else if(tr == -2)
					"-2"
				else if(tr == -1)
					"-1"
				else if(tr == -0.5)
					"-0,5"
				else if(tr == 0) "0" else Global.dblStr(tr))
			}
			wp.bewertung1 = Global.intStrFormat(bew.get(0))
			wp.bewertung2 = Global.intStrFormat(bew.get(1))
			wp.bewertung3 = Global.intStrFormat(bew.get(2))
			wp.bewertung4 = Global.intStrFormat(bew.get(3))
			wp.bewertung5 = Global.intStrFormat(bew.get(4))
			wp.bewertung = Global.format("{0,number,00}",
				bew.get(0) + bew.get(1) + bew.get(2) + bew.get(3) + bew.get(4))
			wp.trend1 = t.get(0)
			wp.trend2 = t.get(1)
			wp.trend3 = t.get(2)
			wp.trend4 = t.get(3)
			wp.trend5 = t.get(4)
			wp.trend = Global.format("{0,number,0}",
				Global.strInt(t.get(0)) + Global.strInt(t.get(1)) + Global.strInt(t.get(2)) + Global.strInt(t.get(3)) +
					Global.strInt(t.get(4)))
			wp.kursdatum = kursdatum.toString
			wp.signalbew = Global.intStr(signalbew)
			wp.signaldatum = if(signaldatum === null) "" else signaldatum.toString
			wp.signalbez = signalbez
			var int[] ia = #[182, 730, 1460, 3650]
			var double[] mina = #[0, 0, 0, 0]
			var double[] maxa = #[0, 0, 0, 0]
			var double[] difa = #[0, 0, 0, 0]
			var bis = liste.get(liste.size - 1).datum
			var min0 = liste.get(liste.size - 1).close
			for (var i = 0; i < ia.length; i++) {
				var datumi = bis.minusDays(ia.get(i))
				var mini = min0
				var maxi = 0.0
				var diff = 0.0
				for (ku : liste) {
					if(datumi.isBefore(ku.datum)) {
						// && datumi.hour == 0 && datumi.minute == 0 && datumi.second == 0) {
						// evtl. aktuellen Kurs ignorieren
						diff = diff + ku.open - ku.close
						if(Global.compDouble(diff, maxi) > 0)
							maxi = diff
						if(Global.compDouble(diff, mini) < 0)
							mini = diff
					}
				}
				mina.set(i, mini)
				maxa.set(i, maxi)
				difa.set(i, diff)
			}
			wp.index1 = Global.dblStr(ClIndex(difa.get(0), mina.get(0), maxa.get(0)))
			wp.index2 = Global.dblStr(ClIndex(difa.get(1), mina.get(1), maxa.get(1)))
			wp.index3 = Global.dblStr(ClIndex(difa.get(2), mina.get(2), maxa.get(2)))
			wp.index4 = Global.dblStr(ClIndex(difa.get(3), mina.get(3), maxa.get(3)))
			var datum14 = bis.minusDays(14)
			var datum200 = bis.minusDays(200)
			var datum214 = bis.minusDays(214)
			var summe14 = 0.0
			var summe200 = 0.0
			var summe214 = 0.0
			var anzahl14 = 0
			var anzahl200 = 0
			var anzahl214 = 0
			for (ku : liste) {
				if(datum14.isBefore(ku.datum)) {
					summe14 += ku.close
					anzahl14++
				}
				if(datum200.isBefore(ku.datum)) {
					summe200 += ku.close
					anzahl200++
				}
				if(datum214.isBefore(ku.datum)) {
					summe214 += ku.close
					anzahl214++
				}
			}
			summe214 -= summe14
			anzahl214 -= anzahl14
			if(anzahl200 > 0 && anzahl214 > 0) {
				var schnitt200 = summe200 / anzahl200
				var schnitt214 = summe214 / anzahl214
				wp.schnitt200 = Global.compDouble(schnitt200, schnitt214).toString
			}
		} catch(Exception ex) {
			wp.bewertung = "00 Fehler: " + ex.message
		// throw new RuntimeException(ex)
		} finally {
			if(speichern) {
				var String[] b = #[wp.bewertung, wp.bewertung1, wp.bewertung2, wp.bewertung3, wp.bewertung4,
					wp.bewertung5, wp.trend1, wp.trend2, wp.trend3, wp.trend4, wp.trend5, wp.trend, wp.kursdatum, wp.xo,
					wp.signalbew, wp.signaldatum, wp.signalbez, wp.index1, wp.index2, wp.index3, //
					wp.index4, wp.schnitt200]
				try {
					iuWertpapier(daten, wp.uid, wp.bezeichnung, wp.kuerzel, wp.aktuellerkurs,
						Global.dblStr2l(wp.signalkurs1), wp.signalkurs2, wp.stopkurs, wp.muster, wp.sortierung, b,
						wp.datenquelle, wp.status, wp.relationUid, wp.notiz)
				} catch(Exception e) {
					Global.machNichts
				}
			}
		}
	}

	def private double ClIndex(double diff, double mini, double maxi) {
		if(Global.compDouble(mini, maxi) == 0) {
			return 0
		} else {
			return (diff - mini) / (maxi - mini)
		}
	}

	def private List<SoKurse> holeKurseIntern(ServiceDaten daten, LocalDate dvon, LocalDate dbis, String kursname,
		String kursnameRelation) {

		var liste = holeKurse(daten, dvon, dbis, kursname, true)
		if(!Global.nes(kursnameRelation)) {
			var rliste = new ArrayList<SoKurse>
			var liste2 = holeKurse(daten, dvon, dbis, kursnameRelation, true)
			var h = new HashMap<Long, SoKurse>
			for (SoKurse k : liste2) {
				h.put(k.datum.toEpochSecond(ZoneOffset.UTC), k)
			}
			var anfang = true
			var faktor = 0.0
			for (SoKurse k : liste) {
				var k2 = h.get(k.datum.toEpochSecond(ZoneOffset.UTC))
				if(k2 !== null && Global.compDouble4(k.close, 0) != 0 && Global.compDouble4(k2.close, 0) != 0) {
					if(anfang) {
						faktor = k2.close / k.close * 100
						anfang = false
					}
					k.setClose(k.close / k2.close * faktor)
					if(Global.compDouble4(k.open, 0) != 0 && Global.compDouble4(k2.open, 0) != 0) {
						k.setOpen(k.open / k2.open * faktor)
					} else {
						k.setOpen(0)
					}
					if(Global.compDouble4(k.high, 0) != 0 && Global.compDouble4(k2.high, 0) != 0) {
						k.setHigh(k.high / k2.high * faktor)
					} else {
						k.setHigh(0)
					}
					if(Global.compDouble4(k.low, 0) != 0 && Global.compDouble4(k2.low, 0) != 0) {
						k.setLow(k.low / k2.low * faktor)
					} else {
						k.setLow(0)
					}
					rliste.add(k)
				}
			}
			liste = rliste
		}
		return liste
	}

	def private List<SoKurse> holeKurse(ServiceDaten daten, LocalDate dvon, LocalDate dbis, String kursname,
		boolean letzter) {

		var von = dvon
		var bis = dbis
		if(bis === null) {
			bis = daten.heute
		}
		if(von === null || !von.isBefore(bis)) {
			von = bis.minusDays(182)
		}
		// http://real-chart.finance.yahoo.com/table.csv?s=%5EGDAXI&d=1&e=10&f=2015&g=d&a=10&b=26&c=2010&ignore=.csv
		var wp = kursname
		if(Global.nes(wp)) {
			wp = "^GDAXI"
		}
		// try {
		// wp = URLEncoder.encode(wp, "UTF-8")
		// } catch (UnsupportedEncodingException ex) {
		// throw new RuntimeException(ex)
		// }
		// var url = Global.format(
		// "http://real-chart.finance.yahoo.com/table.csv?s={0}&d={1}&e={2}&f={3,number,0}&g=d&a={4}&b={5}&c={6,number,0}&ignore=.csv",
		// wp, bis.monthValue - 1, bis.dayOfMonth, bis.year, von.monthValue - 1, von.dayOfMonth, von.year)
		// Ranges 1d 5d 1mo 3mo 6mo 1y 2y 5y 10y ytd max
		// var range = "5d"
		// var url = Global.format(
		// "http://query1.finance.yahoo.com/v7/finance/chart/{0}?range={1}&interval=1d&indicators=quote&includeTimestamps=true",
		// wp, range)
		var url = Global.format(
			"http://query1.finance.yahoo.com/v7/finance/chart/{0}?period1={1}&period2={2}&interval=1d&indicators=quote&includeTimestamps=true",
			wp, dvon.atStartOfDay(ZoneOffset.UTC).toEpochSecond.toString,
			dbis.atStartOfDay(ZoneOffset.UTC).toEpochSecond.toString)
		var v = executeHttp(url, null, false, null)
		var kl = 0.0
		var liste = new ArrayList<SoKurse>
		if(v !== null && v.size > 0) {
			try {
				var jr = new JSONObject(v.get(0))
				var jc = jr.getJSONObject("chart")
				var error = jc.get("error")
				if(error !== null) {
					throw new Exception(error.toString)
				}
				var jresult = jc.getJSONArray("result").getJSONObject(0)
				var jmeta = jresult.getJSONObject("meta")
				var jts = if(jresult.has("timestamp")) jresult.getJSONArray("timestamp") else null
				var jquote = jresult.getJSONObject("indicators").getJSONArray("quote").getJSONObject(0)
				var jopen = jquote.getJSONArray("open")
				var jclose = jquote.getJSONArray("close")
				var jlow = jquote.getJSONArray("low")
				var jhigh = jquote.getJSONArray("high")
				for (var i = 0; jts !== null && i < jts.size; i++) {
					var k = new SoKurse
					k.datum = Instant.ofEpochSecond(jts.getLong(i)).atZone(ZoneId.systemDefault()).toLocalDate().
						atStartOfDay
					k.open = jopen.optDouble(i, 0)
					k.high = jhigh.optDouble(i, 0)
					k.low = jlow.optDouble(i, 0)
					k.close = jclose.optDouble(i, 0)
					k.bewertung = jmeta.getString("currency")
					if(Global.compDouble4(kl, 0) == 0) {
						kl = k.close
					}
					if(Global.compDouble4(k.close, 0) != 0) {
						k.open = if(Global.compDouble4(k.open, 0) == 0) k.close else k.open
						k.high = if(Global.compDouble4(k.open, 0) == 0) k.close else k.high
						k.low = if(Global.compDouble4(k.open, 0) == 0) k.close else k.low
						while(Global.compDouble4(kl, 0) != 0 && Global.compDouble4(k.close / kl, 5) > 0) {
							// richtig skalieren: bei WATL.L Faktor 100. 
							k.open = k.open / 10
							k.high = k.high / 10
							k.low = k.low / 10
							k.close = k.close / 10
						}
						liste.add(k)
					}
				}
			} catch(Exception ex) {
				throw new RuntimeException(ex)
			}
		}

		// Datum aufsteigend
		Collections.sort(liste) [ k1, k2 |
			if(k1.datum === null) {
				if(k2.datum === null) {
					return 0
				}
				return 1
			} else if(k2.datum === null) {
				return -1
			}
			return k1.datum.compareTo(k2.datum)
		]

		//if(letzter && !bis.isBefore(daten.heute)) {
		//	var k = getAktKurs(daten, wp, daten.heute, kl, false)
		//	if(k !== null) {
		//		var ll = if(liste.size <= 0) null else liste.get(liste.size - 1)
		//		if(ll === null || k.datum.isAfter(ll.datum))
		//			liste.add(k)
		//	}
		//}
		return liste
	}

	var df0 = DateTimeFormatter.ofPattern("M/d/yyyy", Locale.ENGLISH)
	var df = DateTimeFormatter.ofPattern("h:mma", Locale.ENGLISH)

	def private SoKurse getAktKurs(ServiceDaten daten, String kuerzel, LocalDate heute, double kl) {

		if(Global.nes(kuerzel)) {
			return null
		}
		//var kurz = kuerzel
		//var url = Global.format("http://download.finance.yahoo.com/d/quotes.csv?s={0}&f=snad1t1c4", kurz) // geht nach 01.11.2017 nicht mehr
		//var v = executeHttp(url, null, true, null)
		//var url = Global.format("https://uk.finance.yahoo.com/quote/AAPL/history")
		//var cookie = new StringBuffer
		//var v = executeHttp(url, null, true, cookie)
		//if (cookie.length > 0) {
		//	url = Global.format("https://download.finance.yahoo.com/d/quotes.csv?s={0}&f=snad1t1c4", kurz)
		//	v = executeHttp(url, null, true, cookie)
		//}
		//if(v !== null && v.size > 0) {
		//	for (String s : v) {
		//		if(!Global.nes(s)) {
		//			try {
		//				var zeile = Global.decodeCSV(s)
		//				if(zeile.size >= 6) {
		//					var k = new SoKurse
		//					var d = LocalDate.parse(zeile.get(3).toUpperCase, df0)
		//					var t = LocalTime.parse(zeile.get(4).toUpperCase, df)
		//					k.datum = d.atTime(t.hour, t.minute)
		//					k.open = Global.strDbl(zeile.get(2))
		//					while(Global.compDouble4(kl, 0) != 0 && Global.compDouble4(k.open / kl, 5) > 0) {
		//						// richtig skalieren: bei WATL.L Faktor 100. 
		//						k.open = k.open / 10
		//					}
		//					k.high = k.open
		//					k.low = k.open
		//					k.close = k.open
		//					k.bemerkung = Global.anhaengen(zeile.get(0), " ", zeile.get(1))
		//					k.bewertung = zeile.get(5) // Währung
		//					if(Global.compDouble4(k.close, 0) != 0) {
		//						return k
		//					}
		//				}
		//			} catch(Exception ex) {
		//				// throw ex
		//			}
		//		}
		//	}
		//}
		var von = heute.minusDays(7)
		var l = holeKurse(daten, von, heute, kuerzel, false)
		if(l !== null && l.size > 0) {
			return l.get(l.size - 1)
		}
		return null
	}

	def private SoKurse getAktWaehrungKurs(ServiceDaten daten, String kuerzel, LocalDate heute) {

		if(Global.nes(kuerzel)) {
			return null
		}
		if(kuerzel == "EUR") {
			var k = new SoKurse
			k.close = 1
			k.bewertung = "EUR"
			return k
		}
		var url = '''https://api.fixer.io/«heute»?symbols=«kuerzel»'''
		var v = executeHttps(url, null, false, null)
		if(v !== null && v.size > 0) {
			try {
				var jr = new JSONObject(v.get(0))
				// var base = jr.getString("base")
				var jresult = jr.getJSONObject("rates")
				if(jresult.has(kuerzel)) {
					var k = new SoKurse
					k.datum = LocalDate.parse(jr.getString("date")).atStartOfDay
					k.close = jresult.optDouble(kuerzel)
					if (Global.compDouble(k.close, 0) != 0)
						k.close = Global.rundeBetrag4(1 / k.close)
					k.open = k.close
					k.high = k.close
					k.low = k.close
					k.bewertung = kuerzel
					return k
				}
			} catch(Exception ex) {
				throw new RuntimeException(ex)
			}
		}
		return null
	}

	def private List<String> executeHttp(String targetURL, String urlParameters, boolean lines, StringBuffer cookie) {

		var URL url
		var HttpURLConnection connection = null
		try {
			// Create connection
			url = new URL(targetURL)
			connection = url.openConnection as HttpURLConnection
			if(!Global.nes(urlParameters)) {
				connection.requestMethod = "POST"
				connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded")
				connection.setRequestProperty("Content-Length", "" + Integer.toString(urlParameters.bytes.length))
				connection.setRequestProperty("Content-Language", "en-US")
				connection.useCaches = false
				connection.doInput = true
			}
			if (cookie !== null && cookie.length > 0) {
				connection.requestMethod = "POST"
				connection.setRequestProperty("Cookie", cookie.toString)
				connection.useCaches = false
				connection.doInput = true
			}
			connection.doOutput = true
			connection.connectTimeout = 3000
			connection.readTimeout = 3000

			// Send request
			var wr = new DataOutputStream(connection.getOutputStream)
			if(!Global.nes(urlParameters)) {
				wr.writeBytes(urlParameters)
			}
			wr.flush
			wr.close

			// Get Response
			if (cookie !== null && cookie.length <= 0) {
				var cookies = connection.getHeaderFields.get("set-cookie")
				if (cookies !== null && cookies.length > 0) {
					var c = cookies.get(0)
					if (c !== null)
						cookie.append(c.split(" ").get(0))
				}
				return null
			}
			if(connection.responseCode != HttpURLConnection.HTTP_OK) {
				throw new Exception(Global.format("Status: {0} bei {1}", connection.responseCode, targetURL))
			}
			var is = connection.getInputStream
			var rd = new BufferedReader(new InputStreamReader(is, "UTF-8"))
			var v = new ArrayList<String>
			var String line
			while((line = rd.readLine) !== null) {
				v.add(line)
			}
			if(!lines && v.length > 1) {
				var sb = new StringBuilder
				for (s : v) {
					sb.append(s)
				}
				v.clear
				v.add(sb.toString)
			}
			rd.close
			return v
		} catch(Exception ex) {
			throw new RuntimeException(ex)
		} finally {
			if(connection !== null) {
				connection.disconnect
			}
		}
	}

	def private List<String> executeHttps(String targetURL, String urlParameters, boolean lines, StringBuffer cookie) {

		var URL url
		var HttpsURLConnection connection = null
		try {
			// Create connection
			url = new URL(targetURL)
			connection = url.openConnection as HttpsURLConnection
			connection.connectTimeout = 3000
			connection.readTimeout = 3000
			if(connection.responseCode != HttpURLConnection.HTTP_OK) {
				throw new Exception(Global.format("Status: {0} bei {1}", connection.responseCode, targetURL))
			}
			var is = connection.getInputStream
			var rd = new BufferedReader(new InputStreamReader(is, "UTF-8"))
			var v = new ArrayList<String>
			var String line
			while((line = rd.readLine) !== null) {
				v.add(line)
			}
			if(!lines && v.length > 1) {
				var sb = new StringBuilder
				for (s : v) {
					sb.append(s)
				}
				v.clear
				v.add(sb.toString)
			}
			rd.close
			return v
		} catch(Exception ex) {
			throw new RuntimeException(ex)
		} finally {
			if(connection !== null) {
				connection.disconnect
			}
		}
	}

	/**
	 * Anlegen oder Ändern eines Wertpapiers.
	 * @param daten Service-Daten mit Mandantennummer.
	 * @param uid Wertpapier-Nummer.
	 * @param bez Bezeichnung.
	 * @param kuerzel Kürzel für Datenabfrage.
	 * @param aktkurs0 Aktueller Kurs.
	 * @param signal1 1. Signalkurs.
	 * @param signal20 2. Signalkurs.
	 * @param stop0 Stopkurs.
	 * @param muster0 letztes erkanntes Muster.
	 * @param sort Sortiermerkmal.
	 * @param bew0 Array von Bewertungen.
	 * @param quelle Datenquelle.
	 * @param status Status.
	 * @param ruid Relation zu anderem Wertpapier.
	 * @param notiz Notiz.
	 */
	def private WpWertpapier iuWertpapier(ServiceDaten daten, String uid, String bez, String kuerzel, String aktkurs0,
		String signal1, String signal20, String stop0, String muster0, String sort, String[] bew0, String quelle,
		String status, String ruid, String notiz) {

		var strB = bez
		var strQ = quelle
		var strStatus = status
		var aktkurs = aktkurs0
		var signal2 = signal20
		var stop = stop0
		var muster = muster0
		var bew = bew0

		if(Global.nes(uid)) {
			if(Global.nes(strB)) {
				strB = "Wertpapier" + kuerzel
			}
			if(Global.nes(strStatus)) {
				strStatus = "0"
			}
		} else {
			if(Global.nes(strB)) {
				throw new MeldungException("Die Bezeichnung darf nicht leer sein.")
			}
			if(Global.nes(status)) {
				throw new MeldungException("Der Status darf nicht leer sein.")
			}
		}
		if(Global.nes(kuerzel)) {
			throw new MeldungException("Das Kürzel darf nicht leer sein.")
		}
		if(Global.nes(strQ)) {
			strQ = "yahoo"
		}
		if(!Global.nes(uid) && bew === null) {
			// Update aus Formular
			var w = getWertpapierLangIntern(daten, uid)
			aktkurs = w.aktuellerkurs
			signal2 = w.signalkurs2
			stop = w.stopkurs
			muster = w.muster
			bew = #[w.bewertung, w.bewertung1, w.bewertung2, w.bewertung3, w.bewertung4, w.bewertung5, w.trend1,
				w.trend2, w.trend3, w.trend4, w.trend5, w.trend, w.kursdatum, w.xo, w.signalbew, w.signaldatum, //
				w.signalbez, w.index1, w.index2, w.index3, w.index4, w.schnitt200]
		}
		var sb = new StringBuilder
		sb.append(Global.dblStr2l(Global.strDbl(aktkurs)))
		sb.append(";").append(Global.dblStr2l(Global.strDbl(signal1)))
		sb.append(";").append(Global.dblStr2l(Global.strDbl(signal2)))
		sb.append(";").append(Global.dblStr2l(Global.strDbl(stop)))
		sb.append(";").append(muster)
		sb.append(";").append(sort)
		for (var i = 0; bew !== null && i < bew.length; i++) {
			sb.append(";")
			if(bew.get(i) !== null) {
				sb.append(bew.get(i))
			}
		}
		return wertpapierRep.iuWpWertpapier(daten, null, uid, strB, kuerzel, sb.toString, strQ, strStatus, ruid, notiz,
			null, null, null, null)
	}

	def private WpWertpapierLang getWertpapierLangIntern(ServiceDaten daten, String uid) {

		var l = wertpapierRep.getWertpapierLangListe(daten, null, null, uid, null, null, false)
		if(l.size > 0) {
			return fillWertpapier(l.get(0), null)
		}
		return null
	}

	@Transaction(false)
	override ServiceErgebnis<WpWertpapierLang> getWertpapierLang(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<WpWertpapierLang>(getWertpapierLangIntern(daten, uid))
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<Void> deleteWertpapier(ServiceDaten daten, String uid) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var liste = wertpapierRep.getWertpapierLangListe(daten, null, null, null, null, uid, false)
		if(liste.size > 0) {
			throw new MeldungException(
				"Das Wertpapier wird in einer Relation verwendet und kann nicht gelöscht werden.")
		}
		var aliste = anlageRep.getAnlageLangListe(daten, null, null, uid)
		if(aliste.size > 0) {
			throw new MeldungException("Das Wertpapier wird in einer Anlage verwendet und kann nicht gelöscht werden.")
		}
		wertpapierRep.delete(daten, new WpWertpapierKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<WpWertpapier> insertUpdateWertpapier(ServiceDaten daten, String uid, String bez,
		String kuerzel, String signal1, String sort, String quelle, String status, String ruid, String notiz) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var e = iuWertpapier(daten, uid, bez, kuerzel, null, signal1, null, null, null, sort, null, quelle, status,
			ruid, notiz)
		var r = new ServiceErgebnis<WpWertpapier>(e)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<SoKurse>> holeKurse(ServiceDaten daten, LocalDate dvon, LocalDate dbis,
		String kursname, String kursnameRelation) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<List<SoKurse>>(holeKurseIntern(daten, dvon, dbis, kursname, kursnameRelation))
		return r
	}

	def private List<String> getWertpapierSpalten() {

		var l = newArrayList("Kursdatum", "Konfiguration", "Uid", "Bezeichnung", "RelationBezeichnung", "Bewertung",
			"Trend", "Bewertung1", "Trend1", "Bewertung2", "Trend2", "Bewertung3", "Trend3", "Bewertung4", "Trend4",
			"Bewertung5", "Trend5", "Aktuellerkurs", "Signalkurs1", "Stopkurs", "Signalkurs2", "Muster", //
			"Sortierung", "Kuerzel", "Xo", "Signalbew", "Signaldatum", "Signalbez", "Index1", "Index2", "Index3",
			"Index4", "Schnitt200", "GeaendertAm", "GeaendertVon", "AngelegtAm", "AngelegtVon")
		return l
	}

	@Transaction(false)
	override ServiceErgebnis<List<String>> exportWertpapierListe(ServiceDaten daten, String bez, String muster,
		String uid, String kuid, LocalDate datum, int tage, StringBuffer status, StringBuffer abbruch) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var felder = getWertpapierSpalten
		var l = new ArrayList<String>
		l.add(Global.encodeCSV(felder))
		var LocalDate d
		var anzahl = tage
		if(datum !== null && tage > 0) {
			d = Global.werktag(datum)
		} else {
			anzahl = 1
		}
		var array = if(Global.nes(kuid)) newArrayOfSize(1) else kuid.split(";")
		while(anzahl > 0) {
			for (k : array) {
				var liste = getWertpapierListeIntern(daten, true, bez, muster, uid, d, k, true, false, status, abbruch)
				exportListeFuellen(felder, liste, new WpWertpapierLang, l)
			}
			if(d !== null) {
				d = Global.werktag(d.minusDays(1))
			}
			anzahl--
		}
		var r = new ServiceErgebnis<List<String>>(l)
		return r
	}

	/**
	 * Zeichnen eines Point & Figure-Charts.
	 */
	def private void paintChart(PnfChart c, Graphics2D p) {

		val xgroesse = c.xgroesse as double
		val ygroesse = c.ygroesse as double
		val max = c.getPosmax as double
		val xoffset = xgroesse * 1.5
		val yoffset = ygroesse * 4.0
		val xanzahl = c.getSaeulen().size as double
		val yanzahl = c.getWerte().size as double
		var b = 0.0
		var h = 0.0
		var x = 0.0
		var y = 0.0
		val fontx = new Font("TimesRoman", Font.PLAIN, (ygroesse + 1.5) as int)
		val fontplain = new Font("TimesRoman", Font.PLAIN, ygroesse as int)
		val fontbold = new Font("TimesRoman", Font.BOLD, ygroesse as int)

		var stroke = 1.2
		var color = Color.black
		var font = fontplain

		// Werte schreiben
		stroke = 0.5
		color = Color.lightGray
		x = xoffset + (xanzahl + 2) * xgroesse
		y = yoffset + c.werte.size * ygroesse
		var aktkurs = c.kurs
		var yakt = -1;
		if(Global.compDouble4(aktkurs, 0) > 0) {
			var d = c.getMax() + 1;
			for (var i = 0; i < yanzahl; i++) {
				if(Global.compDouble4(c.werte.get(i), d) < 0 && Global.compDouble4(c.werte.get(i), aktkurs) > 0) {
					d = c.werte.get(i)
					yakt = i
				}
			}
		}
		for (var i = 0; i < yanzahl + 1; i++) {
			if(i < yanzahl) {
				if(i == yakt) {
					font = fontbold
					color = Color.black
					drawString(p, x + 5, y, Global.dblStr(Global.round(aktkurs)), font, color)
					font = fontplain
					color = Color.lightGray
				} else {
					drawString(p, x + 5, y, Global.dblStr(Global.round(c.getWerte().get(i))), font, color)
				}
			}
			drawLine(p, xoffset, y, x, y, color, stroke) // waagerechte Linien
			y -= ygroesse
		}

		// Datumswerte schreiben
		x = xoffset
		y = yoffset + yanzahl * ygroesse
		for (var i = 0; i < xanzahl + 3; i++) {
			drawLine(p, x, yoffset, x, y, color, stroke) // senkrechte Linien
			if(i % 6 == 0 && i < xanzahl && c.getSaeulen().get(i).getDatum() !== null) {
				drawString(p, x + xgroesse, y + ygroesse * 1.5,
					Global.dateTimeStringForm(c.getSaeulen().get(i).getDatum()), font, color)
			}
			x += xgroesse
		}

		// Säulen
		stroke = 1.2
		drawString(p, xoffset, ygroesse * 2, c.bezeichnung, font, color)
		drawString(p, xoffset, ygroesse * 3.3, c.bezeichnung2, font, color)
		b = xoffset + xgroesse
		h = 0
		// var xd = xgroesse / 2
		// var yd = ygroesse / 2
		for (s : c.saeulen) {
			h = s.getYpos()
			var array = s.chars
			for (char xo : array) {
				x = b
				y = (max - h + 1) * ygroesse + yoffset
				if(xo == Character.valueOf('O')) {
					color = Color.red
					// drawOval(p, x + xd, y - xd, xd - 1, yd - 1, stroke, color)
					drawOval(p, x + 1, y - ygroesse + 1, xgroesse - 2, ygroesse - 2, stroke, color)
				} else if(xo == Character.valueOf('X')) {
					color = Color.green
					drawString(p, x + 1, y, "X", fontx, color)
				} else {
					color = Color.black
					drawString(p, x + 2, y - 1, String.valueOf(xo), font, color)
				}
				h += 1
			}
			b += xgroesse
		}

		// Trendlinien
		stroke = 2
		for (t : c.trends) {
			x = (t.getXpos() + 1) * xgroesse + xoffset
			y = (max - t.getYpos()) * ygroesse + yoffset
			b = t.getLaenge() * xgroesse
			if(t.getBoxtyp() == 0) {
				b += xgroesse
				h = 0
				color = Color.red
			} else if(t.getBoxtyp() == 1) {
				h = -t.getLaenge() * ygroesse
				color = Color.blue
			} else {
				h = t.getLaenge() * ygroesse
				y += ygroesse
				color = Color.blue
			}
			drawLine(p, x, y, x + b, y + h, color, stroke)
		}

		// Muster
		stroke = 2
		color = new Color(0.5803922f, 0.0f, 0.827451f) // DARKVIOLET
		for (pa : c.getPattern()) {
			x = (pa.getXpos() + 1) * xgroesse + xoffset
			y = (max - pa.getYpos()) * ygroesse + yoffset
			drawString(p, x, y, pa.getBezeichnung(), font, color)
		}
	}

	def private void drawOval(Graphics2D p, double x, double y, double w, double h, double stroke, Color color) {

		// p.fill(null)
		p.paint = color
		p.stroke = new BasicStroke(stroke as float)
		p.draw(new Ellipse2D.Double(x, y, w, h))
	// p.drawOval(x as int, y as int, w as int,h as int)
	}

	def private void drawString(Graphics2D p, double x, double y, String str, Font font, Color color) {

		p.font = font
		p.paint = color
		p.drawString(str, x as int, y as int)
	}

	def private void drawLine(Graphics2D p, double x, double y, double x2, double y2, Color color, double stroke) {

		p.paint = color
		p.stroke = new BasicStroke(stroke as float)
		p.draw(new Line2D.Double(x, y, x2, y2));
	}

//	def private List<SoKurse> getChart(ServiceDaten daten, WpWertpapierLang wp, WpKonfigurationLang k, LocalDate dbis,
//		List<SoKurse> l, HSSFWorkbook wb, HSSFSheet sheet, int cp, int rp, HSSFRow row) {
//
//		var dvon = dbis.minusDays(k.dauer)
//		var liste = if(l === null)
//				holeKurseIntern(daten, dvon, dbis, wp.kuerzel, if(k !== null && k.relativ) wp.relationKuerzel else null)
//			else
//				l
//		val c = new PnfChart
//		c.box = k.box
//		c.bezeichnung = wp.bezeichnung
//		c.ziel = wp.signalkurs1
//		c.stop = Global.strDbl(wp.stopkurs)
//		c.methode = k.methode
//		c.skala = k.skala
//		c.umkehr = k.umkehr
//		c.relativ = k.relativ
//		c.addKurse(liste)
//		var d0 = c.computeDimension(500, 500)
//		var d = c.getDimension(d0.width, d0.height)
//		var width = d.width
//		var height = d.height
//
//		row.heightInPoints = (height * 0.75) as float
//		sheet.setColumnWidth(cp, width * 40)
//		// TYPE_INT_ARGB specifies the image format: 8-bit RGBA packed into integer pixels
//		var bi = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB)
//		var ig2 = bi.createGraphics
//		paintChart(c, ig2)
//
//		var pictureIdx = 0
//		var osp = new ByteArrayOutputStream
//		try {
//			ImageIO.write(bi, "PNG", osp)
//		} finally {
//			osp.flush
//			pictureIdx = wb.addPicture(osp.toByteArray, Workbook.PICTURE_TYPE_PNG)
//			osp.close
//		}
//		var drawing = sheet.createDrawingPatriarch
//		var helper = wb.getCreationHelper()
//		// add a picture shape
//		var anchor = helper.createClientAnchor
//		// set top-left corner of the picture,
//		// subsequent call of Picture#resize() will operate relative to it
//		anchor.setCol1(cp)
//		anchor.setRow1(rp)
//		var pict = drawing.createPicture(anchor, pictureIdx)
//		// auto-size picture relative to its top-left corner
//		pict.resize
//		return liste
//	}

	@Transaction(false)
	override ServiceErgebnis<byte[]> exportWertpapierVergleichListe(ServiceDaten daten, String uid, String kuid,
		LocalDate datum, LocalDate datum2, LocalDate datum3, StringBuffer status, StringBuffer abbruch) {

		// getBerechService.pruefeBerechtigungAktuellerMandant(daten, mandantNr)
		var r = new ServiceErgebnis<byte[]>
		//var warray = if(Global.nes(uid)) newArrayOfSize(1) else uid.split(";")
		if(Global.nes(uid) || datum === null || datum2 === null || datum3 === null) {
			return r
		}
//		var wb = new HSSFWorkbook
//		var WpKonfigurationLang k = null
//		if(!Global.nes(kuid)) {
//			var l = konfigurationRep.getKonfigurationLangListe(daten, kuid, null)
//			if(Global.listLaenge(l) > 0) {
//				k = fillKonfiguration(l.get(0))
//				k.relativ = false
//				k.bezeichnung = PnfChart.getBezeichnung(k.bezeichnung, 0, k.skala, k.umkehr, k.methode, k.relativ,
//					k.dauer, null, 0, 0)
//			}
//		}
//		if(k === null) {
//			k = new WpKonfigurationLang
//			k.bezeichnung = "ohne Konfiguration"
//			k.dauer = 182
//			k.methode = 4
//			k.umkehr = 3
//		}
//		k.skala = 1 // prozentual
//		k.relativ = false
//		var zeiten = #[datum, datum2, datum3]
//		var us = #['''Kauf «datum.toString»''', '''Verkauf «datum2.toString»''', '''Aktuell «datum3.toString»''']
//		var double[] boxen = #[5, 2, 1, 1]
//		var dauern = #[5 * 365 + 1, 365 + 182, 182, 5 * 365 + 1]
//
//		for (wuid : warray) {
//			var cp = -3
//			var wp = getWertpapierLangIntern(daten, wuid)
//			status.length = 0
//			status.append(wp.bezeichnung)
//			var wp1 = if(Global.nes(wp.relationUid)) null else getWertpapierLangIntern(daten, wp.relationUid)
//			var wp2 = wp
//			var sheet = wb.createSheet(wp.bezeichnung)
//			var row0 = sheet.createRow(0)
//			var row2 = sheet.createRow(2)
//			var row3 = sheet.createRow(3)
//			var row5 = sheet.createRow(5)
//			var row6 = sheet.createRow(6)
//			for (var i = 0; i <= 2 && abbruch.length <= 0; i++) {
//				// if (i==0)
//				// throw new MeldungException(Meldungen.M1000)
//				var rp = 3
//				cp = cp + 3
//				var dbis = zeiten.get(i)
//				var cell = row0.createCell(cp)
//				cell.cellValue = us.get(i)
//				if(wp1 !== null) {
//					// var List<SoKurse> liste
//					k.box = boxen.get(0)
//					k.dauer = dauern.get(0)
//					k.relativ = false
//					getChart(daten, wp1, k, dbis, null, wb, sheet, cp, rp - 1, row2)
//					k.box = boxen.get(1)
//					k.dauer = dauern.get(1)
//					getChart(daten, wp1, k, dbis, null, wb, sheet, cp + 1, rp - 1, row2)
//					k.box = boxen.get(2)
//					k.dauer = dauern.get(3)
//					getChart(daten, wp1, k, dbis, null, wb, sheet, cp, rp, row3)
//				}
//				rp = rp + 3
//				if(wp2 !== null) {
//					k.box = boxen.get(0)
//					k.dauer = dauern.get(0)
//					k.relativ = false
//					getChart(daten, wp2, k, dbis, null, wb, sheet, cp, rp - 1, row5)
//					k.box = boxen.get(1)
//					k.dauer = dauern.get(1)
//					getChart(daten, wp2, k, dbis, null, wb, sheet, cp + 1, rp - 1, row5)
//					k.box = boxen.get(2)
//					k.dauer = dauern.get(2)
//					getChart(daten, wp2, k, dbis, null, wb, sheet, cp, rp, row6)
//					if(wp1 !== null) {
//						k.box = boxen.get(3)
//						k.dauer = dauern.get(3)
//						k.relativ = true
//						wp2.bezeichnung = Global.anhaengen(new StringBuffer(wp2.bezeichnung), " (",
//							wp2.relationBezeichnung, ")").toString
//						getChart(daten, wp2, k, dbis, null, wb, sheet, cp + 1, rp, row6)
//					}
//				}
//			}
//		}
//		var os = new ByteArrayOutputStream
//		try {
//			wb.write(os)
//		} finally {
//			os.flush
//			r.ergebnis = os.toByteArray
//			os.close
//		}
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<WpAnlageLang>> getAnlageListe(ServiceDaten daten, boolean zusammengesetzt, String bez,
		String uid, String wpuid) {

		var liste = getAnlageLangListeIntern(daten, zusammengesetzt, bez, uid, wpuid, null, null, null)
		var r = new ServiceErgebnis<List<WpAnlageLang>>(liste)
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<List<WpAnlageLang>> bewerteteAnlageListe(ServiceDaten daten, boolean zusammengesetzt,
		String bez, String uid, String wpuid, LocalDate bewertungsdatum, StringBuffer status, StringBuffer abbruch) {

		var r = new ServiceErgebnis<List<WpAnlageLang>>(null)
		var liste = getAnlageLangListeIntern(daten, zusammengesetzt, bez, uid, wpuid, bewertungsdatum, status, abbruch)
		r.ergebnis = liste
		return r
	}

	def private List<WpAnlageLang> getAnlageLangListeIntern(ServiceDaten daten, boolean zusammengesetzt, String bez,
		String uid, String wpuid, LocalDate bewertungsdatum, StringBuffer status, StringBuffer abbruch) {

		var liste = anlageRep.getAnlageLangListe(daten, bez, uid, wpuid)
		if(bewertungsdatum !== null) {
			val bis = bewertungsdatum
			val l = liste.size
			for (var i = 0; i < l && abbruch.length <= 0; i++) {
				val a = liste.get(i)
				status.length = 0
				status.append('''(«i+1» von «l») Berechnung von «a.wertpapierBezeichnung», «a.bezeichnung» am «bis»''')
				var array = if(Global.nes(a.parameter)) newArrayOfSize(0) else a.parameter.split(";")
				var waehrung = if(array.size >= 10 && !Global.excelNes(array.get(9))) array.get(9) else ''
				var kurs = if(array.size >= 11 && !Global.excelNes(array.get(10)))
						Global.strDbl(array.get(10))
					else
						1
				var wp = getWertpapierLangIntern(daten, a.wertpapierUid)
				var bliste = buchungRep.getBuchungLangListe(daten, null, null, null, a.uid, false)
				var betrag = bliste.map[b|b.zahlungsbetrag].reduce[sum, x|sum + x]
				betrag = if(betrag === null) 0.0 else betrag
				var rabatt = bliste.map[b|b.rabattbetrag].reduce[sum, x|sum + x]
				rabatt = if(rabatt === null) 0.0 else rabatt
				betrag = betrag - rabatt
				var anteile = bliste.map[b|b.anteile].reduce[sum, x|sum + x]
				anteile = if(anteile === null) 0.0 else anteile
				var preis = if(anteile == 0) 0 else betrag / anteile
				var zinsen = bliste.map[b|b.zinsen].reduce[sum, x|sum + x]
				zinsen = if(zinsen === null) 0.0 else zinsen
				var SoKurse k
				try {
					k = getAktKurs(daten, wp.kuerzel, bis, preis)
				} catch(Exception ex) {
					// ignorieren
					Global.machNichts
				}
				if(k === null) {
					var s = standRep.getAktStand(daten, wp.uid, null)
					if(s !== null) {
						k = new SoKurse
						k.close = s.stueckpreis
						k.datum = s.datum.atStartOfDay
					}
				} else {
					waehrung = k.bewertung
				}
				if(!Global.nes(waehrung)) {
					waehrung = waehrung.toUpperCase
					var SoKurse wk
					//try {
						wk = getAktWaehrungKurs(daten, waehrung, bis)
					//} catch(Exception ex) {
					//	// ignorieren
					//}
					if(wk !== null) {
						kurs = wk.close
					}
				}
				var aktpreis = if(k === null) 0 else k.close * kurs
				var datum = if(k === null) null else k.datum
				var wert = anteile * aktpreis
				var gewinn = wert + zinsen - betrag
				var pw = if(wert == 0) 0 else gewinn / betrag * 100
				var sb = new StringBuilder
				sb.append(Global.dblStr2l(betrag))
				sb.append(";").append(Global.dblStr5l(anteile))
				sb.append(";").append(Global.dblStr4l(preis))
				sb.append(";").append(Global.dblStr2(zinsen))
				sb.append(";").append(Global.dblStr4l(aktpreis))
				sb.append(";").append(if(datum === null) '' else datum.toString)
				sb.append(";").append(Global.dblStr2l(wert))
				sb.append(";").append(Global.dblStr2l(gewinn))
				sb.append(";").append(Global.dblStr2l(pw))
				sb.append(";").append(Global.nn(waehrung))
				sb.append(";").append(Global.dblStr4l(kurs))
				a.parameter = sb.toString
				anlageRep.iuWpAnlage(daten, null, a.uid, a.wertpapierUid, a.bezeichnung, a.parameter, a.notiz, null,
					null, null, null)
			}
		}
		for (a : liste) {
			var array = if(Global.nes(a.parameter)) null else a.parameter.split(";")
			var l = Global.arrayLaenge(array)
			if(l >= 11) {
				a.betrag = Global.strDbl(array.get(0))
				a.anteile = Global.strDbl(array.get(1))
				a.preis = Global.strDbl(array.get(2))
				a.zinsen = Global.strDbl(array.get(3))
				a.aktpreis = Global.strDbl(array.get(4))
				a.aktdatum = if(Global.nes(array.get(5))) null else LocalDateTime.parse(array.get(5))
				a.wert = Global.strDbl(array.get(6))
				a.gewinn = Global.strDbl(array.get(7))
				a.pgewinn = Global.strDbl(array.get(8))
				a.waehrung = array.get(9)
				a.kurs = Global.strDbl(array.get(10))
			}
			if(zusammengesetzt) {
				// a.bezeichnung = Global.anhaengen(new StringBuffer(a.wertpapierBezeichnung), ", ", a.bezeichnung).
				// toString
				a.daten = '''
					«IF a.anteile != 0»
						Zahlungssumme: «Global.dblStr2l(a.betrag)»
						Anteilssumme:  «Global.dblStr5l(a.anteile)»
						Preis/Anteil:  «Global.dblStr4l(a.preis)»
						Zinsen:        «Global.dblStr2l(a.zinsen)»
						«IF a.aktpreis != 0»
							Aktueller Preis: «Global.dblStr4l(a.aktpreis)»«IF !Global.nes(a.waehrung)» («a.waehrung» «Global.dblStr4l(a.kurs)»)«ENDIF»«IF a.aktdatum === null»«ELSE» («a.aktdatum»)«ENDIF»
							Aktueller Wert: «Global.dblStr2l(a.wert)»
							Gewinn/Verlust: «Global.dblStr2l(a.gewinn)» («Global.dblStr4l(a.pgewinn)» %)
						«ENDIF»
					«ENDIF»
				'''
			}
		}
		return liste
	}

	@Transaction(false)
	override ServiceErgebnis<WpAnlageLang> getAnlageLang(ServiceDaten daten, String uid) {

		var l = getAnlageLangListeIntern(daten, true, null, uid, null, null, null, null)
		var r = new ServiceErgebnis<WpAnlageLang>(if(l.size > 0) l.get(0) else null)
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<WpAnlage> insertUpdateAnlage(ServiceDaten daten, String uid, String wpuid, String bez,
		String notiz) {

		if(Global.nes(bez)) {
			throw new MeldungException("Die Bezeichnung darf nicht leer sein.")
		}
		if(Global.nes(wpuid) || wertpapierRep.get(daten, new WpWertpapierKey(daten.mandantNr, wpuid)) === null) {
			throw new MeldungException("Ein Wertpapier muss ausgewählt werden.")
		}
		var String parameter = null
		if(!Global.nes(uid)) {
			var a = anlageRep.get(daten, new WpAnlageKey(daten.mandantNr, uid))
			if(a !== null) {
				parameter = a.parameter
			}
		}
		var e = anlageRep.iuWpAnlage(daten, null, uid, wpuid, bez, parameter, notiz, null, null, null, null)
		var r = new ServiceErgebnis<WpAnlage>(e)
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<Void> deleteAnlage(ServiceDaten daten, String uid) {

		var bliste = buchungRep.getBuchungLangListe(daten, null, null, null, uid, false)
		if(bliste.size > 0) {
			throw new MeldungException("Die Anlage wird in einer Buchung verwendet und kann nicht gelöscht werden.")
		}
		anlageRep.delete(daten, new WpAnlageKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<WpBuchungLang>> getBuchungListe(ServiceDaten daten, boolean zusammengesetzt,
		String bez, String uid, String wpuid, String auid) {

		var r = new ServiceErgebnis<List<WpBuchungLang>>(null)
		var liste = buchungRep.getBuchungLangListe(daten, bez, uid, wpuid, auid, true)
//		for (WpBuchungLang e : liste) {
//			if (zusammengesetzt) {
//				e.bezeichnung = Global.anhaengen(new StringBuffer(e.wertpapierBezeichnung), ", ", e.bezeichnung).
//					toString
//			}
//		}
		r.ergebnis = liste
		return r
	}

	def private WpBuchungLang getBuchungLangIntern(ServiceDaten daten, String uid) {

		var l = buchungRep.getBuchungLangListe(daten, null, uid, null, null, false)
		if(l.size > 0) {
			var b = l.get(0)
			return b
		}
		return null
	}

	@Transaction(false)
	override ServiceErgebnis<WpBuchungLang> getBuchungLang(ServiceDaten daten, String uid) {

		var r = new ServiceErgebnis<WpBuchungLang>(getBuchungLangIntern(daten, uid))
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<WpBuchung> insertUpdateBuchung(ServiceDaten daten, String uid, String auid,
		LocalDate datum, double betrag, double rabatt, double anteile, double zinsen, String btext, //
		String notiz, double stand) {

		var WpAnlage anlage
		if(!Global.nes(auid)) {
			anlage = anlageRep.get(daten, new WpAnlageKey(daten.mandantNr, auid))
		}
		if(anlage === null) {
			throw new MeldungException("Eine Anlage muss ausgewählt werden.")
		}
		if(datum === null) {
			throw new MeldungException("Es ist kein Valuta festgelegt.")
		}
		if(Global.nes(btext)) {
			throw new MeldungException("Es ist kein Buchungstext erfasst.")
		}
		if(Global.compDouble(betrag, 0) == 0 && Global.compDouble(rabatt, 0) == 0 &&
			Global.compDouble4(anteile, 0) == 0 && Global.compDouble(zinsen, 0) == 0) {
			throw new MeldungException("Es muss ein Betrag oder Anteil erfasst werden.")
		}
		var WpBuchung balt
		if(!Global.nes(uid)) {
			balt = buchungRep.get(daten, new WpBuchungKey(daten.mandantNr, uid))
		}
		var e = buchungRep.iuWpBuchung(daten, null, uid, anlage.wertpapierUid, auid, datum, betrag, rabatt, anteile,
			zinsen, btext, notiz, null, null, null, null)

		// Stand korrigieren
		var stand2 = stand
		if(balt !== null && balt.datum != datum) {
			if(balt.wertpapierUid == anlage.wertpapierUid && stand == 0) {
				// Datum-Änderung nimmt den Stand mit
				var st = standRep.get(daten, new WpStandKey(daten.mandantNr, balt.wertpapierUid, balt.datum))
				if(st !== null) {
					stand2 = st.stueckpreis
					standRep.delete(daten, new WpStandKey(daten.mandantNr, balt.wertpapierUid, balt.datum))
				}
			}
			if(balt.wertpapierUid != anlage.wertpapierUid) {
				standRep.delete(daten, new WpStandKey(daten.mandantNr, balt.wertpapierUid, balt.datum))
			}
		}
		if(Global.compDouble(stand2, 0) <= 0) {
			standRep.delete(daten, new WpStandKey(daten.mandantNr, anlage.wertpapierUid, datum))
		} else {
			standRep.iuWpStand(daten, null, anlage.wertpapierUid, datum, stand2, null, null, null, null)
		}
		var r = new ServiceErgebnis<WpBuchung>(e)
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<Void> deleteBuchung(ServiceDaten daten, String uid) {

		buchungRep.delete(daten, new WpBuchungKey(daten.mandantNr, uid))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<List<WpStandLang>> getStandListe(ServiceDaten daten, boolean zusammengesetzt, String wpuid,
		LocalDate von, LocalDate bis) {

		var r = new ServiceErgebnis<List<WpStandLang>>(null)
		var liste = standRep.getStandLangListe(daten, wpuid, von, bis, true)
		// for (WpAnlageLang e : liste) {
		// if (zusammengesetzt) {
		// e.bezeichnung = Global.anhaengen(new StringBuffer(e.wertpapierBezeichnung), ", ", e.bezeichnung).
		// toString
		// }
		// }
		r.ergebnis = liste
		return r
	}

	@Transaction(false)
	override ServiceErgebnis<WpStand> getStand(ServiceDaten daten, String wpuid, LocalDate datum) {

		var r = new ServiceErgebnis<WpStand>(standRep.get(daten, new WpStandKey(daten.mandantNr, wpuid, datum)))
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<WpStand> insertUpdateStand(ServiceDaten daten, String wpuid, LocalDate datum,
		double betrag) {

		if(Global.nes(wpuid) || wertpapierRep.get(daten, new WpWertpapierKey(daten.mandantNr, wpuid)) === null) {
			throw new MeldungException("Ein Wertpapier muss ausgewählt werden.")
		}
		var e = standRep.iuWpStand(daten, null, wpuid, datum, betrag, null, null, null, null)
		var r = new ServiceErgebnis<WpStand>(e)
		return r
	}

	@Transaction(true)
	override ServiceErgebnis<Void> deleteStand(ServiceDaten daten, String wpuid, LocalDate datum) {

		standRep.delete(daten, new WpStandKey(daten.mandantNr, wpuid, datum))
		var r = new ServiceErgebnis<Void>(null)
		return r
	}

}
