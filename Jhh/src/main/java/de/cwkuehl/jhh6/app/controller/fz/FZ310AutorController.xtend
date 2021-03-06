package de.cwkuehl.jhh6.app.controller.fz

import de.cwkuehl.jhh6.api.dto.FzBuchautor
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TextField

/** 
 * Controller für Dialog FZ310Autor.
 */
class FZ310AutorController extends BaseController<FzBuchautor> {

	@FXML Label nr0
	@FXML TextField nr
	@FXML Label name0
	@FXML TextField name
	@FXML Label vorname0
	@FXML TextField vorname
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
		name0.setLabelFor(name, true)
		vorname0.setLabelFor(vorname)
		angelegt0.setLabelFor(angelegt)
		geaendert0.setLabelFor(geaendert)
		initDaten(0)
		name.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			var neu = DialogAufrufEnum::NEU.equals(aufruf)
			var loeschen = DialogAufrufEnum::LOESCHEN.equals(aufruf)
			var FzBuchautor k = parameter1
			if (!neu && k !== null) {
				k = get(FactoryService::freizeitService.getAutor(serviceDaten, k.uid))
				nr.setText(k.uid)
				name.setText(k.name)
				vorname.setText(k.vorname)
				angelegt.setText(k.formatDatumVon(k.angelegtAm, k.angelegtVon))
				geaendert.setText(k.formatDatumVon(k.geaendertAm, k.geaendertVon))
			}
			nr.setEditable(false)
			name.setEditable(!loeschen)
			vorname.setEditable(!loeschen)
			angelegt.setEditable(false)
			geaendert.setEditable(false)
			if (loeschen) {
				ok.setText(Meldungen::M2001)
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

		var ServiceErgebnis<?> r
		var FzBuchautor s
		if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
			var r1 = FactoryService::freizeitService.insertUpdateAutor(serviceDaten, null, name.text, vorname.text)
			s = r1.ergebnis
			r = r1
		} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
			r = FactoryService::freizeitService.insertUpdateAutor(serviceDaten, nr.text, name.text, vorname.text)
		} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
			r = FactoryService::freizeitService.deleteAutor(serviceDaten, nr.text)
		}
		if (r !== null) {
			get(r)
			if (r.fehler.isEmpty) {
				updateParent
				close(s)
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
