package de.cwkuehl.jhh6.app.controller.hh

import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.HhPeriodeLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.Profil
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
import javafx.scene.control.TextField
import javafx.scene.control.ToggleGroup
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog HH100Perioden.
 */
class HH100PeriodenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button loeschen
	@FXML Label perioden0
	// @FXML Label anfang0
	@FXML TextField anfang
	// @FXML Label ende0
	@FXML TextField ende
	@FXML Label laenge0
	@FXML @Profil(defaultValue="1") ToggleGroup laenge
	@FXML Label art0
	@FXML @Profil(defaultValue="1") ToggleGroup art
	@FXML TableView<PeriodenData> perioden
	@FXML TableColumn<PeriodenData, Integer> colNr
	@FXML TableColumn<PeriodenData, String> colText
	@FXML TableColumn<PeriodenData, LocalDate> colVon
	@FXML TableColumn<PeriodenData, LocalDate> colBis
	@FXML TableColumn<PeriodenData, LocalDateTime> colGa
	@FXML TableColumn<PeriodenData, String> colGv
	@FXML TableColumn<PeriodenData, LocalDateTime> colAa
	@FXML TableColumn<PeriodenData, String> colAv
	ObservableList<PeriodenData> periodenData = FXCollections.observableArrayList

	/** 
	 * Daten für Tabelle Perioden.
	 */
	static class PeriodenData extends TableViewData<HhPeriodeLang> {

		SimpleObjectProperty<Integer> nr
		SimpleStringProperty text
		SimpleObjectProperty<LocalDate> datumVon
		SimpleObjectProperty<LocalDate> datumBis
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(HhPeriodeLang v) {

			super(v)
			nr = new SimpleObjectProperty<Integer>(v.getNr)
			text = new SimpleStringProperty(v.getText)
			datumVon = new SimpleObjectProperty<LocalDate>(v.getDatumVon)
			datumBis = new SimpleObjectProperty<LocalDate>(v.getDatumBis)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.getGeaendertAm)
			geaendertVon = new SimpleStringProperty(v.getGeaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.getAngelegtAm)
			angelegtVon = new SimpleStringProperty(v.getAngelegtVon)
		}

		override String getId() {
			return Global.intStr(getData.getNr)
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		perioden0.setLabelFor(perioden)
		laenge0.setLabelFor(laenge, false)
		art0.setLabelFor(art, false)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("L", loeschen)
		initDaten(0)
		perioden.setPrefHeight(2000)
		perioden.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			anfang.setEditable(false)
			ende.setEditable(false)
		}
		if (stufe <= 1) {
			var List<HhPeriodeLang> l = get(FactoryService.getHaushaltService.getPeriodeListe(getServiceDaten))
			getItems(l, null, [a|new PeriodenData(a)], periodenData)
			if (l !== null && l.size > 0) {
				anfang.setText(Global.dateTimeStringForm(l.get(l.size - 1).getDatumVon.atStartOfDay))
				ende.setText(Global.dateTimeStringForm(l.get(0).getDatumBis.atStartOfDay))
			}
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		perioden.setItems(periodenData)
		colNr.setCellValueFactory([c|c.getValue.nr])
		colText.setCellValueFactory([c|c.getValue.text])
		colVon.setCellValueFactory([c|c.getValue.datumVon])
		colBis.setCellValueFactory([c|c.getValue.datumBis])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(perioden, 1)
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

		get(
			FactoryService.getHaushaltService.anlegenPeriode(getServiceDaten, Global.strInt(getText(laenge)),
				Global.strInt(getText(art)) !== 0))
		onAktuell
	}

	/** 
	 * Event für Loeschen.
	 */
	@FXML def void onLoeschen() {
		get(FactoryService.getHaushaltService.loeschePeriode(getServiceDaten, Global.strInt(getText(art)) !== 0))
		onAktuell
	}

	/** 
	 * Event für Perioden.
	 */
	@FXML def void onPeriodenMouseClick(MouseEvent e) {
		if (e.getClickCount > 1) {
			// onAendern
		}
	}
}