package de.cwkuehl.jhh6.app.controller.sb

import de.cwkuehl.jhh6.api.dto.SbFamilieLang
import de.cwkuehl.jhh6.api.dto.SbPersonLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDateTime
import javafx.application.Platform
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog SB300Familien.
 */
class SB300FamilienController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label familien0
	@FXML TableView<FamilienData> familien
	@FXML TableColumn<FamilienData, String> colUid
	@FXML TableColumn<FamilienData, String> colVater
	@FXML TableColumn<FamilienData, String> colMutter
	@FXML TableColumn<FamilienData, LocalDateTime> colGa
	@FXML TableColumn<FamilienData, String> colGv
	@FXML TableColumn<FamilienData, LocalDateTime> colAa
	@FXML TableColumn<FamilienData, String> colAv
	ObservableList<FamilienData> familienData = FXCollections::observableArrayList

	// @FXML Label springen0
	// @FXML Button spVater
	// @FXML Button spMutter
	// @FXML Button spKind
	/** 
	 * Daten für Tabelle Familien.
	 */
	static class FamilienData extends BaseController.TableViewData<SbFamilieLang> {

		SimpleStringProperty uid
		SimpleStringProperty vater
		SimpleStringProperty mutter
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(SbFamilieLang v) {

			super(v)
			uid = new SimpleStringProperty(v.uid)
			vater = new SimpleStringProperty(v.vaterGeburtsname)
			mutter = new SimpleStringProperty(v.mutterGeburtsname)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.geaendertAm)
			geaendertVon = new SimpleStringProperty(v.geaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.angelegtAm)
			angelegtVon = new SimpleStringProperty(v.angelegtVon)
		}

		override String getId() {
			return uid.get
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		familien0.setLabelFor(familien)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		familien.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) { // stufe = 0
		}
		if (stufe <= 1) {
			var l = get(FactoryService::stammbaumService.getFamilieListe(serviceDaten, true))
			getItems(l, null, [a|new FamilienData(a)], familienData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		familien.setItems(familienData)
		colUid.setCellValueFactory([c|c.value.uid])
		colVater.setCellValueFactory([c|c.value.vater])
		colMutter.setCellValueFactory([c|c.value.mutter])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var SbFamilieLang k = getValue(familien, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(typeof(SB310FamilieController), aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(familien, 1)
	}

	/** 
	 * Event für Rueckgaengig.
	 */
	@FXML def void onRueckgaengig() {
		get(Jhh6::rollback)
		onAktuell
	}

	/** 
	 * Event für Wiederherstellen.
	 */
	@FXML def void onWiederherstellen() {
		get(Jhh6::redo)
		onAktuell
	}

	/** 
	 * Event für Neu.
	 */
	@FXML def void onNeu() {
		starteDialog(DialogAufrufEnum::NEU)
	}

	/** 
	 * Event für Kopieren.
	 */
	@FXML def void onKopieren() {
		starteDialog(DialogAufrufEnum::KOPIEREN)
	}

	/** 
	 * Event für Aendern.
	 */
	@FXML def void onAendern() {
		starteDialog(DialogAufrufEnum::AENDERN)
	}

	/** 
	 * Event für Loeschen.
	 */
	@FXML def void onLoeschen() {
		starteDialog(DialogAufrufEnum::LOESCHEN)
	}

	/** 
	 * Event für Familien.
	 */
	@FXML def void onFamilienMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	/** 
	 * Event für SpVater.
	 */
	@FXML def void onSpVater() {

		val SbFamilieLang k = getValue(familien, true)
		val c = fokusFormular(typeof(SB200AhnenController), DialogAufrufEnum::OHNE) as SB200AhnenController
		if (c !== null) {
			Platform::runLater([c.onSpFamilieVater(k.mannUid)])
		}
	}

	/** 
	 * Event für SpMutter.
	 */
	@FXML def void onSpMutter() {

		val SbFamilieLang k = getValue(familien, true)
		val c = fokusFormular(typeof(SB200AhnenController), DialogAufrufEnum::OHNE) as SB200AhnenController
		if (c !== null) {
			Platform::runLater([c.onSpFamilieMutter(k.frauUid)])
		}
	}

	/** 
	 * Event für SpKind.
	 */
	@FXML def void onSpKind() {

		val SbFamilieLang k = getValue(familien, true)
		val c = fokusFormular(typeof(SB200AhnenController), DialogAufrufEnum::OHNE) as SB200AhnenController
		if (c !== null) {
			Platform::runLater([c.onSpFamilieKind(k.uid)])
		}
	}

	/** 
	 * Event für SpElternFamilie.
	 */
	def void onSpElternFamilie(SbPersonLang k) {

		if (k !== null) {
			var r = get(FactoryService::stammbaumService.getElternFamilie(serviceDaten, k.uid))
			setText(familien, r)
			if (Global::nes(r)) {
				Jhh6::setLeftStatus2(Meldungen::SB027)
			}
		}
	}

	/** 
	 * Event für SpFamilienKind.
	 */
	def void onSpFamilienKind(SbPersonLang k) {

		if (k !== null) {
			var r = get(FactoryService::stammbaumService.getKindFamilie(serviceDaten, k.uid))
			setText(familien, r)
		}
	}
}
