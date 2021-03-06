package de.cwkuehl.jhh6.app.controller.vm

import de.cwkuehl.jhh6.api.dto.VmMieterLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import javafx.fxml.FXML
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TextField

/** 
 * Controller für Dialog VM530Istzahlung.
 */
class VM530IstzahlungController extends BaseController<String> {

	@FXML Label monat0
	@FXML Datum monat
	@FXML Label mieter0
	@FXML ComboBox<MieterData> mieter
	@FXML Label belegDatum0
	@FXML Datum belegDatum
	@FXML Label miete0
	@FXML TextField miete
	@FXML Label garage0
	@FXML TextField garage
	@FXML Label nebenkosten0
	@FXML TextField nebenkosten
	@FXML Label heizung0
	@FXML TextField heizung
	@FXML Label summe0
	@FXML TextField summe
	// @FXML Button ok
	// @FXML Button abbrechen
	static LocalDate monatZuletzt = LocalDate::now.minusMonths(1).withDayOfMonth(1)
	static LocalDate belegDatumZuletzt = LocalDate::now.minusMonths(1).withDayOfMonth(1)

	/** 
	 * Daten für ComboBox Mieter.
	 */
	static class MieterData extends ComboBoxData<VmMieterLang> {

		new(VmMieterLang v) {
			super(v)
		}

		override String getId() {
			return getData.uid
		}

		override String toString() {
			return getData.name
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		monat0.setLabelFor(monat, true)
		mieter0.setLabelFor(mieter, true)
		belegDatum0.setLabelFor(belegDatum, true)
		miete0.setLabelFor(miete, true)
		garage0.setLabelFor(garage)
		nebenkosten0.setLabelFor(nebenkosten)
		heizung0.setLabelFor(heizung)
		summe0.setLabelFor(summe)
		initDaten(0)
		mieter.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			// letzten Monat einstellen
			monat.setValue(monatZuletzt)
			belegDatum.setValue(belegDatumZuletzt)
			var ml = get(FactoryService::vermietungService.getMieterListe(serviceDaten, true, null, null, null, null))
			mieter.setItems(getItems(ml, null, [a|new MieterData(a)], null))
			summe.setEditable(false)
		// onMieter
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
	 * Event für Mieter.
	 */
	@FXML def void onMieter() {

		var vo = get(
			FactoryService::vermietungService.getMieteSollstellung(serviceDaten, monat.value, null, null,
				getText(mieter), false))
		miete.setText(Global::dblStr2l(vo.miete))
		garage.setText(Global::dblStr2l(vo.garage))
		nebenkosten.setText(Global::dblStr2l(vo.nebenkosten))
		heizung.setText(Global::dblStr2l(vo.heizung))
		summe.setText(Global::dblStr2l(vo.miete + vo.garage + vo.nebenkosten + vo.heizung))
	}

	/** 
	 * Event für Summenberechnung.
	 */
	@FXML def void onSummen() {
		var s = Global::strDbl(miete.text) + Global::strDbl(garage.text) + Global::strDbl(nebenkosten.text) +
			Global::strDbl(heizung.text)
		summe.setText(Global::dblStr2l(s))
	}

	/** 
	 * Event für Ok.
	 */
	@FXML def void onOk() {

		var r = FactoryService::vermietungService.insertIstzahlung(serviceDaten, monat.value, belegDatum.value,
			getText(mieter), Global::strDbl(miete.text), Global::strDbl(nebenkosten.text), Global::strDbl(garage.text),
			Global::strDbl(heizung.text))
		if (r !== null) {
			get(r)
			if (r.fehler.isEmpty) {
				// letztes Datum merken
				monatZuletzt = monat.value
				belegDatumZuletzt = belegDatum.value
				miete.setText(null)
				garage.setText(null)
				nebenkosten.setText(null)
				heizung.setText(null)
				summe.setText(null)
				mieter.requestFocus
			}
		}
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}
