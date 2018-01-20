package de.cwkuehl.jhh6.app.controller.wp

import java.time.LocalDate
import java.time.LocalDateTime
import java.util.List
import de.cwkuehl.jhh6.api.dto.WpAnlageLang
import de.cwkuehl.jhh6.api.dto.WpWertpapierLang
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Profil
import de.cwkuehl.jhh6.server.FactoryService
import javafx.application.Platform
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.concurrent.Task
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.control.TextField
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog WP250Anlagen.
 */
class WP250AnlagenController extends BaseController<String> {

	//@FXML Button tab
	@FXML Button aktuell
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label anlagen0
	@FXML TableView<AnlagenData> anlagen
	@FXML TableColumn<AnlagenData, String> colWpbezeichnung
	@FXML TableColumn<AnlagenData, String> colBezeichnung
	@FXML TableColumn<AnlagenData, Double> colBetrag
	@FXML TableColumn<AnlagenData, Double> colWert
	@FXML TableColumn<AnlagenData, Double> colGewinn
	@FXML TableColumn<AnlagenData, String> colWaehrung
	@FXML TableColumn<AnlagenData, LocalDateTime> colGa
	@FXML TableColumn<AnlagenData, String> colGv
	@FXML TableColumn<AnlagenData, LocalDateTime> colAa
	@FXML TableColumn<AnlagenData, String> colAv
	ObservableList<AnlagenData> anlagenData = FXCollections::observableArrayList
	@FXML Label anlagenStatus
	//@FXML Button alle
	//@FXML Button berechnen
	//@FXML Button abbrechen
	@FXML Label bezeichnung0
	@FXML TextField bezeichnung
	@FXML Label wertpapier0
	@FXML ComboBox<WertpapierData> wertpapier
	@Profil String wertpapierUid = null
	/** 
	 * Abbruch-Objekt. 
	 */
	StringBuffer abbruch = new StringBuffer
	/** 
	 * Status zum Anzeigen. 
	 */
	StringBuffer status = new StringBuffer

	/** 
	 * Daten für Tabelle Wertpapiere.
	 */
	static class AnlagenData extends TableViewData<WpAnlageLang> {

		SimpleStringProperty wpbezeichnung
		SimpleStringProperty bezeichnung
		SimpleObjectProperty<Double> betrag
		SimpleObjectProperty<Double> wert
		SimpleObjectProperty<Double> gewinn
		SimpleStringProperty waehrung
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(WpAnlageLang v) {

			super(v)
			wpbezeichnung = new SimpleStringProperty(v.getWertpapierBezeichnung)
			bezeichnung = new SimpleStringProperty(v.getBezeichnung)
			betrag = new SimpleObjectProperty<Double>(v.getBetrag)
			wert = new SimpleObjectProperty<Double>(v.getWert)
			gewinn = new SimpleObjectProperty<Double>(v.getGewinn)
			waehrung = new SimpleStringProperty(v.getWaehrung)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.getGeaendertAm)
			geaendertVon = new SimpleStringProperty(v.getGeaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.getAngelegtAm)
			angelegtVon = new SimpleStringProperty(v.getAngelegtVon)
		}

		override String getId() {
			return getData.getUid
		}
	}

	/** 
	 * Daten für ComboBox Wertpapier.
	 */
	static class WertpapierData extends ComboBoxData<WpWertpapierLang> {

		new(WpWertpapierLang v) {
			super(v)
		}

		override String getId() {
			return getData.getUid
		}

		override String toString() {
			return getData.getBezeichnung
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		anlagen0.setLabelFor(anlagen)
		bezeichnung0.setLabelFor(bezeichnung)
		wertpapier0.setLabelFor(wertpapier, false)
		initAccelerator("A", aktuell)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		anlagen.requestFocus
		anlagen.setPrefHeight(2000)
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			bezeichnung.setText("%%")
			var List<WpWertpapierLang> kliste = get(
				FactoryService::getWertpapierService.getWertpapierListe(getServiceDaten, true, null, null, null))
			wertpapier.setItems(getItems(kliste, new WpWertpapierLang, [a|new WertpapierData(a)], null))
			setText(wertpapier, wertpapierUid)
		}
		if (stufe <= 1) {
			var List<WpAnlageLang> l = get(
				FactoryService::getWertpapierService.getAnlageListe(getServiceDaten, false, bezeichnung.getText,
					null, getText(wertpapier)))
			getItems(l, null, [a|new AnlagenData(a)], anlagenData)
			var int anz = Global::listLaenge(l)
			var double summe = 0
			var double wert = 0
			var double gewinn = 0
			if (l !== null) {
				for (WpAnlageLang b : l) {
					summe += b.getBetrag
					wert += b.getWert
					gewinn += b.getGewinn
				}
			}
			var StringBuffer sb = new StringBuffer
			sb.append(
				Global::format("Datensätze: {0}  Summe: {1}  Wert: {2}  Gewinn: {3}", anz, Global::dblStr(summe),
					Global::dblStr(wert), Global::dblStr(gewinn)))
			anlagenStatus.setText(sb.toString)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		anlagen.setItems(anlagenData)
		colWpbezeichnung.setCellValueFactory([c|c.getValue.wpbezeichnung])
		colBezeichnung.setCellValueFactory([c|c.getValue.bezeichnung])
		colBetrag.setCellValueFactory([c|c.getValue.betrag])
		initColumnBetrag(colBetrag)
		colWert.setCellValueFactory([c|c.getValue.wert])
		initColumnBetrag(colWert)
		colGewinn.setCellValueFactory([c|c.getValue.gewinn])
		initColumnBetrag(colGewinn)
		colWaehrung.setCellValueFactory([c|c.getValue.waehrung])
		colGv.setCellValueFactory([c|c.getValue.geaendertVon])
		colGa.setCellValueFactory([c|c.getValue.geaendertAm])
		colAv.setCellValueFactory([c|c.getValue.angelegtVon])
		colAa.setCellValueFactory([c|c.getValue.angelegtAm])
	}

	override protected void updateParent() {
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {
		var WpAnlageLang k = getValue(anlagen, !DialogAufrufEnum::NEU.equals(aufruf))
		starteFormular(typeof(WP260AnlageController), aufruf, k)
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(anlagen, 1)
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
	 * Event für Anlagen.
	 */
	@FXML def void onAnlagenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	/** 
	 * Event für Alle.
	 */
	@FXML def void onAlle() {
		wertpapierUid = null
		refreshTable(anlagen, 0)
	}

	override protected void onHidden() {
		wertpapierUid = getText(wertpapier)
		super.onHidden
	}

	/** 
	 * Event für Wertpapier.
	 */
	@FXML def void onWertpapier() {
		onAktuell
	}

	/** 
	 * Event für Berechnen.
	 */
	@FXML def void onBerechnen() {

		var Task<Void> task = ([|
			onStatusTimer
			try {
				var ServiceErgebnis<List<WpAnlageLang>> r = FactoryService::getWertpapierService.
					bewerteteAnlageListe(getServiceDaten, false, bezeichnung.getText, null, getText(wertpapier),
						LocalDate::now, status, abbruch)
				r.throwErstenFehler
				status.setLength(0)
			} catch (Exception ex) {
				status.setLength(0)
				status.append('''Fehler: «ex.getMessage»'''.toString)
			} finally {
				abbruch.append("Ende")
			}
			Platform::runLater([
				{
					WP250AnlagenController.this.onAktuell
				}
			])
			return null as Void
		] as Task<Void>)
		var Thread th = new Thread(task)
		th.setDaemon(true)
		th.start
	}

	def private void onStatusTimer() {

		status.setLength(0)
		abbruch.setLength(0)
		onStatus
		var Task<Void> task = ([|
			try {
				while (true) {
					onStatus
					Thread::sleep(1000)
				}
			} catch (Exception ex) {
				Global::machNichts
			}
			return null as Void
		] as Task<Void>)
		var Thread th = new Thread(task)
		th.setDaemon(true)
		th.start
	}

	def private void onStatus() {
		Jhh6::setLeftStatus2(status.toString)
		if (abbruch.length > 0) {
			throw new RuntimeException("")
		}
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		abbruch.append("Abbruch")
	}
}