package de.cwkuehl.jhh6.app.controller.fz

import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.FzFahrradLang
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
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
 * Controller für Dialog FZ200Fahrraeder.
 */
class FZ200FahrraederController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label fahrraeder0
	@FXML TableView<FahrraederData> fahrraeder
	@FXML TableColumn<FahrraederData, String> colUid
	@FXML TableColumn<FahrraederData, String> colBezeichnung
	@FXML TableColumn<FahrraederData, String> colTyp
	@FXML TableColumn<FahrraederData, LocalDateTime> colGa
	@FXML TableColumn<FahrraederData, String> colGv
	@FXML TableColumn<FahrraederData, LocalDateTime> colAa
	@FXML TableColumn<FahrraederData, String> colAv
	ObservableList<FahrraederData> fahrraederData = FXCollections.observableArrayList

	/** 
	 * Daten für Tabelle Fahrraeder.
	 */
	static class FahrraederData extends BaseController.TableViewData<FzFahrradLang> {

		SimpleStringProperty uid
		SimpleStringProperty bezeichnung
		SimpleStringProperty typ
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(FzFahrradLang v) {

			super(v)
			uid = new SimpleStringProperty(v.getUid)
			bezeichnung = new SimpleStringProperty(v.getBezeichnung)
			typ = new SimpleStringProperty(v.getTypBezeichnung)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.getGeaendertAm)
			geaendertVon = new SimpleStringProperty(v.getGeaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.getAngelegtAm)
			angelegtVon = new SimpleStringProperty(v.getAngelegtVon)
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
		fahrraeder0.setLabelFor(fahrraeder)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		fahrraeder.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			 // stufe = 0
		}
		if (stufe <= 1) {
			var List<FzFahrradLang> l = get(
				FactoryService.getFreizeitService.getFahrradListe(getServiceDaten, false))
			getItems(l, null, [a|new FahrraederData(a)], fahrraederData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		fahrraeder.setItems(fahrraederData)
		colUid.setCellValueFactory([c|c.getValue.uid])
		colBezeichnung.setCellValueFactory([c|c.getValue.bezeichnung])
		colTyp.setCellValueFactory([c|c.getValue.typ])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var FzFahrradLang k = getValue(fahrraeder, !DialogAufrufEnum.NEU.equals(aufruf))
		starteFormular(FZ210FahrradController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(fahrraeder, 1)
	}

	/** 
	 * Event für Rueckgaengig.
	 */
	@FXML def void onRueckgaengig() {
		get(Jhh6.rollback)
		onAktuell
	}

	/** 
	 * Event für Wiederherstellen.
	 */
	@FXML def void onWiederherstellen() {
		get(Jhh6.redo)
		onAktuell
	}

	/** 
	 * Event für Neu.
	 */
	@FXML def void onNeu() {
		starteDialog(DialogAufrufEnum.NEU)
	}

	/** 
	 * Event für Kopieren.
	 */
	@FXML def void onKopieren() {
		starteDialog(DialogAufrufEnum.KOPIEREN)
	}

	/** 
	 * Event für Aendern.
	 */
	@FXML def void onAendern() {
		starteDialog(DialogAufrufEnum.AENDERN)
	}

	/** 
	 * Event für Loeschen.
	 */
	@FXML def void onLoeschen() {
		starteDialog(DialogAufrufEnum.LOESCHEN)
	}

	/** 
	 * Event für Fahrraeder.
	 */
	@FXML def void onFahrraederMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}
}