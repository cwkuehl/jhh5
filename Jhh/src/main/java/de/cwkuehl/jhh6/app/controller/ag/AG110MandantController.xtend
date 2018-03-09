package de.cwkuehl.jhh6.app.controller.ag

import de.cwkuehl.jhh6.api.dto.MaMandant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TextField

/** 
 * Controller für Dialog AG110Mandant.
 */
class AG110MandantController extends BaseController<String> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label beschreibung0
	@FXML TextField beschreibung
	@FXML Label angelegt0
	@FXML TextField angelegt
	@FXML Label geaendert0
	@FXML TextField geaendert
	@FXML Button ok

	// @FXML Button abbrechen
	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 0
		nr0.setLabelFor(nr)
		beschreibung0.setLabelFor(beschreibung)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		beschreibung.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var boolean neu = DialogAufrufEnum.NEU.equals(aufruf)
			var boolean kopieren = DialogAufrufEnum.KOPIEREN.equals(aufruf)
			var boolean loeschen = DialogAufrufEnum.LOESCHEN.equals(aufruf)
			var MaMandant k = getParameter1
			if (!neu && k !== null) {
				k = get(FactoryService::anmeldungService.getMandant(serviceDaten, k.nr))
				if (k !== null) {
					nr.text = Global.intStr(k.nr)
					beschreibung.text = k.beschreibung
					angelegt.text = k.formatDatumVon(k.angelegtAm, k.angelegtVon)
					geaendert.text = k.formatDatumVon(k.geaendertAm, k.geaendertVon)
				}
			}
			if (kopieren) {
				nr.setText(null)
			}
			nr.setEditable(neu || kopieren)
			beschreibung.setEditable(!loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen.M2001)
			}
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

		var ServiceErgebnis<?> r = null
		if (DialogAufrufEnum.NEU.equals(aufruf) || DialogAufrufEnum.KOPIEREN.equals(aufruf)) {
			r = FactoryService::anmeldungService.insertUpdateMandant(serviceDaten, Global.strInt(nr.text),
				beschreibung.text, true)
		} else if (DialogAufrufEnum.AENDERN.equals(aufruf)) {
			r = FactoryService::anmeldungService.insertUpdateMandant(serviceDaten, Global.strInt(nr.text),
				beschreibung.text, false)
		} else if (DialogAufrufEnum.LOESCHEN.equals(aufruf)) {
			if (Werkzeug.showYesNoQuestion(Meldungen.AM005) === 0) {
				return
			}
			r = FactoryService::anmeldungService.deleteMandant(serviceDaten, Global.strInt(nr.text))
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
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		close
	}
}
