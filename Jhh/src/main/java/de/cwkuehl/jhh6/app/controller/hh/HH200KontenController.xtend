package de.cwkuehl.jhh6.app.controller.hh

import de.cwkuehl.jhh6.api.dto.HhKonto
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import java.time.LocalDateTime
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
 * Controller für Dialog HH200Konten.
 */
class HH200KontenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label konten0
	@FXML TableView<KontenData> konten
	@FXML TableColumn<KontenData, String> colUid
	@FXML TableColumn<KontenData, String> colArt
	@FXML TableColumn<KontenData, String> colKz
	@FXML TableColumn<KontenData, String> colName
	@FXML TableColumn<KontenData, LocalDate> colVon
	@FXML TableColumn<KontenData, LocalDate> colBis
	@FXML TableColumn<KontenData, LocalDateTime> colGa
	@FXML TableColumn<KontenData, String> colGv
	@FXML TableColumn<KontenData, LocalDateTime> colAa
	@FXML TableColumn<KontenData, String> colAv
	ObservableList<KontenData> kontenData = FXCollections.observableArrayList

	/** 
	 * Daten für Tabelle Konten.
	 */
	static class KontenData extends BaseController.TableViewData<HhKonto> {

		SimpleStringProperty uid
		SimpleStringProperty art
		SimpleStringProperty kz
		SimpleStringProperty name
		SimpleObjectProperty<LocalDate> von
		SimpleObjectProperty<LocalDate> bis
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(HhKonto v) {

			super(v)
			uid = new SimpleStringProperty(v.uid)
			art = new SimpleStringProperty(v.art)
			kz = new SimpleStringProperty(v.kz)
			name = new SimpleStringProperty(v.name)
			von = new SimpleObjectProperty<LocalDate>(v.gueltigVon)
			bis = new SimpleObjectProperty<LocalDate>(v.gueltigBis)
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
		konten0.setLabelFor(konten)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		konten.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
		}
		if (stufe <= 1) {
			var l = get(FactoryService::haushaltService.getKontoListe(serviceDaten, null, null))
			getItems(l, null, [a|new KontenData(a)], kontenData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		konten.setItems(kontenData)
		colUid.setCellValueFactory([c|c.value.uid])
		colArt.setCellValueFactory([c|c.value.art])
		colKz.setCellValueFactory([c|c.value.kz])
		colName.setCellValueFactory([c|c.value.name])
		colVon.setCellValueFactory([c|c.value.von])
		colBis.setCellValueFactory([c|c.value.bis])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var HhKonto k = getValue(konten, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(HH210KontoController, aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(konten, 1)
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
	 * Event für Konten.
	 */
	@FXML def void onKontenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}
}
