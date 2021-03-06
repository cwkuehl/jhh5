package de.cwkuehl.jhh6.app.controller.sb

import de.cwkuehl.jhh6.api.dto.ByteDaten
import de.cwkuehl.jhh6.api.dto.SbPerson
import de.cwkuehl.jhh6.api.dto.SbPersonLang
import de.cwkuehl.jhh6.api.dto.SbQuelle
import de.cwkuehl.jhh6.api.enums.GedcomEreignis
import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DateiAuswahl
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Bild
import de.cwkuehl.jhh6.server.FactoryService
import java.util.function.Consumer
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TextField
import javafx.scene.control.ToggleGroup
import javafx.scene.layout.HBox

/** 
 * Controller für Dialog SB210Ahn.
 */
class SB210AhnController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML HBox bilder
	@FXML Label geburtsname0
	@FXML TextField geburtsname
	@FXML Label vorname0
	@FXML TextField vorname
	@FXML Label name0
	@FXML TextField name
	@FXML Label geschlecht0
	@FXML ToggleGroup geschlecht
	@FXML Label bilddaten0
	@FXML TextArea bilddaten
	@FXML Label geburtsdatum0
	@FXML TextField geburtsdatum
	@FXML Label geburtsort0
	@FXML TextField geburtsort
	@FXML Label geburtsbem0
	@FXML TextArea geburtsbem
	@FXML Label taufdatum0
	@FXML TextField taufdatum
	@FXML Label taufort0
	@FXML TextField taufort
	@FXML Label taufbem0
	@FXML TextArea taufbem
	@FXML Label todesdatum0
	@FXML TextField todesdatum
	@FXML Label todesort0
	@FXML TextField todesort
	@FXML Label todesbem0
	@FXML TextArea todesbem
	@FXML Label begraebnisdatum0
	@FXML TextField begraebnisdatum
	@FXML Label begraebnisort0
	@FXML TextField begraebnisort
	@FXML Label begraebnisbem0
	@FXML TextArea begraebnisbem
	@FXML Label konfession0
	@FXML TextField konfession
	@FXML Label titel0
	@FXML TextField titel
	@FXML Label bemerkung0
	@FXML TextArea bemerkung
	@FXML Label gatte0
	@FXML TextField gatte
	@FXML Label gatteNr0
	@FXML TextField gatteNr
	@FXML Label vater0
	@FXML TextField vater
	@FXML Label vaterNr0
	@FXML TextField vaterNr
	@FXML Label mutter0
	@FXML TextField mutter
	@FXML Label mutterNr0
	@FXML TextField mutterNr
	@FXML Label quelle0
	@FXML ComboBox<QuelleData> quelle
	// @FXML Label status10
	@FXML TextField status1
	// @FXML Label status20
	@FXML TextField status2
	// @FXML Label status30
	@FXML TextField status3
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok
	@FXML Button hinzufuegen
	// @FXML Button abbrechen
	Consumer<String> refresh

	/** 
	 * Daten für ComboBox Quelle.
	 */
	static class QuelleData extends BaseController.ComboBoxData<SbQuelle> {

		new(SbQuelle v) {
			super(v)
		}

		override String getId() {
			return getData.uid
		}

		override String toString() {
			return getData.beschreibung
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		geburtsname0.setLabelFor(geburtsname, true)
		vorname0.setLabelFor(vorname)
		name0.setLabelFor(name)
		geschlecht0.setLabelFor(geschlecht, true)
		bilddaten0.setLabelFor(bilddaten)
		geburtsdatum0.setLabelFor(geburtsdatum)
		geburtsort0.setLabelFor(geburtsort)
		geburtsbem0.setLabelFor(geburtsbem)
		taufdatum0.setLabelFor(taufdatum)
		taufort0.setLabelFor(taufort)
		taufbem0.setLabelFor(taufbem)
		todesdatum0.setLabelFor(todesdatum)
		todesort0.setLabelFor(todesort)
		todesbem0.setLabelFor(todesbem)
		begraebnisdatum0.setLabelFor(begraebnisdatum)
		begraebnisort0.setLabelFor(begraebnisort)
		begraebnisbem0.setLabelFor(begraebnisbem)
		konfession0.setLabelFor(konfession)
		titel0.setLabelFor(titel)
		bemerkung0.setLabelFor(bemerkung)
		gatte0.setLabelFor(gatte)
		gatteNr0.setLabelFor(gatteNr)
		vater0.setLabelFor(vater)
		vaterNr0.setLabelFor(vaterNr)
		mutter0.setLabelFor(mutter)
		mutterNr0.setLabelFor(mutterNr)
		quelle0.setLabelFor(quelle, false)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		refresh = [ s |
			bilddaten.setText(Global::anhaengen(bilddaten.text, Constant::CRLF, s))
		]
		Bild::addDragNdrop(bilder, refresh)
		initDaten(0)
		geburtsname.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var l = get(FactoryService::stammbaumService.getQuelleListe(serviceDaten, true))
			quelle.setItems(getItems(l, new SbQuelle, [a|new QuelleData(a)], null))
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var SbPersonLang k = parameter1
			if (!neu && k !== null) {
				k = get(FactoryService::stammbaumService.getPersonLang(serviceDaten, k.uid))
				if (k !== null) {
					nr.setText(k.uid)
					name.setText(k.name)
					vorname.setText(k.vorname)
					geburtsname.setText(k.geburtsname)
					setText(geschlecht, k.geschlecht)
					titel.setText(k.titel)
					konfession.setText(k.konfession)
					bemerkung.setText(k.bemerkung)
					vater.setText(Global::ahnString(k.vaterUid, k.vaterGeburtsname, k.vaterVorname, false, false))
					mutter.setText(Global::ahnString(k.mutterUid, k.mutterGeburtsname, k.mutterVorname, false, false))
					if (DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
						vaterNr.setText(k.vaterUid)
						mutterNr.setText(k.mutterUid)
					}
					setText(quelle, k.quelleUid)
					status1.setText(Global::intStrFormat(k.status1))
					status2.setText(Global::intStrFormat(k.status2))
					status3.setText(Global::intStrFormat(k.status3))
					angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
					geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
					var liste = get(
						FactoryService::stammbaumService.getPersonEreignis(serviceDaten, k.uid,
							GedcomEreignis::eGEBURT.wert))
					if (Global::listLaenge(liste) >= 3) {
						geburtsdatum.setText(liste.get(0))
						geburtsort.setText(liste.get(1))
						geburtsbem.setText(liste.get(2))
					}
					liste = get(
						FactoryService::stammbaumService.getPersonEreignis(serviceDaten, k.uid,
							GedcomEreignis::eTAUFE.wert))
					if (Global::listLaenge(liste) >= 3) {
						taufdatum.setText(liste.get(0))
						taufort.setText(liste.get(1))
						taufbem.setText(liste.get(2))
					}
					liste = get(
						FactoryService::stammbaumService.getPersonEreignis(serviceDaten, k.uid,
							GedcomEreignis::eTOD.wert))
					if (Global::listLaenge(liste) >= 3) {
						todesdatum.setText(liste.get(0))
						todesort.setText(liste.get(1))
						todesbem.setText(liste.get(2))
					}
					liste = get(
						FactoryService::stammbaumService.getPersonEreignis(serviceDaten, k.uid,
							GedcomEreignis::eBEGRAEBNIS.wert))
					if (Global::listLaenge(liste) >= 3) {
						begraebnisdatum.setText(liste.get(0))
						begraebnisort.setText(liste.get(1))
						begraebnisbem.setText(liste.get(2))
					}
					if (DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
						gatteNr.setText(k.uid)
					}
					var pliste = get(FactoryService::stammbaumService.getEhegatten(serviceDaten, k.uid))
					if (Global::listLaenge(pliste) > 0) {
						var sb = new StringBuffer
						for (SbPerson p : pliste) {
							Global::anhaengen(sb, "; ",
								Global::ahnString(p.uid, p.geburtsname, p.vorname, false, false))
						}
						gatte.setText(sb.toString)
					}
					var byteliste = get(FactoryService::heilpraktikerService.getPatientBytesListe(serviceDaten, k.uid))
					if (byteliste !== null) {
						for (ByteDaten bd : byteliste) {
							if (bd.bytes !== null && bd.metadaten !== null) {
								new Bild(bilder, null, bd.bytes, null, bd.metadaten, refresh)
							}
						}
					}
				}
			}
			nr.setEditable(false)
			name.setEditable(!loeschen)
			vorname.setEditable(!loeschen)
			geburtsname.setEditable(!loeschen)
			setEditable(geschlecht, !loeschen)
			bilddaten.setEditable(!loeschen)
			geburtsdatum.setEditable(!loeschen)
			geburtsort.setEditable(!loeschen)
			geburtsbem.setEditable(!loeschen)
			taufdatum.setEditable(!loeschen)
			taufort.setEditable(!loeschen)
			taufbem.setEditable(!loeschen)
			todesdatum.setEditable(!loeschen)
			todesort.setEditable(!loeschen)
			todesbem.setEditable(!loeschen)
			begraebnisdatum.setEditable(!loeschen)
			begraebnisort.setEditable(!loeschen)
			begraebnisbem.setEditable(!loeschen)
			titel.setEditable(!loeschen)
			konfession.setEditable(!loeschen)
			bemerkung.setEditable(!loeschen)
			gatte.setEditable(false)
			gatteNr.setEditable(!loeschen)
			vater.setEditable(false)
			vaterNr.setEditable(!loeschen)
			mutter.setEditable(false)
			mutterNr.setEditable(!loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen::M2001)
			}
			hinzufuegen.setVisible(!loeschen)
		}
		if (stufe <= 1) { // stufe = 0
		}
		if (stufe <= 2) { // initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var ServiceErgebnis<?> r
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			r = FactoryService::stammbaumService.insertUpdatePerson(serviceDaten, null, name.text, vorname.text,
				geburtsname.text, getText(geschlecht), titel.text, konfession.text, bemerkung.text, getText(quelle),
				Global::strInt(status1.text), Global::strInt(status2.text), Global::strInt(status3.text),
				geburtsdatum.text, geburtsort.text, geburtsbem.text, null, taufdatum.text, taufort.text, taufbem.text,
				null, todesdatum.text, todesort.text, todesbem.text, null, begraebnisdatum.text, begraebnisort.text,
				begraebnisbem.text, null, gatteNr.text, vaterNr.text, mutterNr.text,
				Bild::parseBilddaten(bilddaten.text, Bild::getBytesListe(bilder)))
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::stammbaumService.insertUpdatePerson(serviceDaten, nr.text, name.text, vorname.text,
				geburtsname.text, getText(geschlecht), titel.text, konfession.text, bemerkung.text, getText(quelle),
				Global::strInt(status1.text), Global::strInt(status2.text), Global::strInt(status3.text),
				geburtsdatum.text, geburtsort.text, geburtsbem.text, null, taufdatum.text, taufort.text, taufbem.text,
				null, todesdatum.text, todesort.text, todesbem.text, null, begraebnisdatum.text, begraebnisort.text,
				begraebnisbem.text, null, gatteNr.text, vaterNr.text, mutterNr.text,
				Bild::parseBilddaten(bilddaten.text, Bild::getBytesListe(bilder)))
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::stammbaumService.deletePerson(serviceDaten, nr.text)
		}
		if (r !== null) {
			get(r)
			if (r.fehler.isEmpty) {
				updateParent
				close
			}
		}
	}

	/** 
	 * Event für Hinzufuegen.
	 * @FXML
	 */
	def void onHinzufuegen() {
		var datei = DateiAuswahl::auswaehlen(true, "SB210.select.file", "SB210.select.ok", "ged", "SB210.select.ext")
		if (!Global::nes(datei)) {
			new Bild(bilder, datei, null, null, null, refresh)
		}
	}

	/** 
	 * Event für Abbrechen.
	 * @FXML
	 */
	def void onAbbrechen() {
		close
	}
}
