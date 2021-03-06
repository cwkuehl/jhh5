package de.cwkuehl.jhh6.app.controller.hh

import de.cwkuehl.jhh6.api.dto.HhBilanzSb
import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.control.Datum
import de.cwkuehl.jhh6.server.FactoryService
import java.time.LocalDate
import java.util.ArrayList
import java.util.List
import javafx.application.Platform
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.concurrent.Task
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.input.MouseEvent

/** 
 * Controller für Dialog HH500Bilanzen.
 */
class HH500BilanzenController extends BaseController<String> {

	@FXML Button berechnen
	@FXML Button rueckgaengig
	@FXML Button wiederherstellen
	@FXML Button drucken
	@FXML Label soll0
	@FXML TableView<SollData> soll
	@FXML TableColumn<SollData, String> colKontoUid
	@FXML TableColumn<SollData, String> colName
	@FXML TableColumn<SollData, Double> colBetrag
	ObservableList<SollData> sollData = FXCollections.observableArrayList
	@FXML Label haben0
	@FXML TableView<SollData> haben
	@FXML TableColumn<SollData, String> colhKontoUid
	@FXML TableColumn<SollData, String> colhName
	@FXML TableColumn<SollData, Double> colhBetrag
	ObservableList<SollData> habenData = FXCollections.observableArrayList
	// @FXML Label sollSumme0
	@FXML Label sollBetrag0
	// @FXML Label habenSumme0
	@FXML Label habenBetrag0
	@FXML Label von0
	@FXML Datum von
	@FXML Label bis0
	@FXML Datum bis
	// @FXML Label konto0
	// @FXML Button oben
	// @FXML Button unten
	int mlBerechnen = 0
	boolean sollTabelle

	/** 
	 * Daten für Tabelle Soll und Haben.
	 */
	static class SollData extends TableViewData<HhBilanzSb> {

		SimpleStringProperty kontoUid
		SimpleStringProperty name
		SimpleObjectProperty<Double> betrag

		new(HhBilanzSb v) {

			super(v)
			kontoUid = new SimpleStringProperty(v.kontoUid)
			name = new SimpleStringProperty(v.name)
			betrag = new SimpleObjectProperty<Double>(v.esumme)
		}

		override String getId() {
			return kontoUid.get
		}
	}

	/** 
	 * Titel des Dialogs.
	 */
	override protected String getTitel() {
		return super.getTitel(parameter1)
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		soll0.setLabelFor(soll)
		haben0.setLabelFor(haben)
		von0.setLabelFor(von.labelForNode)
		bis0.setLabelFor(bis.labelForNode)
		initAccelerator("B", berechnen)
		initAccelerator("U", rueckgaengig)
		initAccelerator("W", wiederherstellen)
		initAccelerator("D", drucken)
		soll.selectionModel.selectedItemProperty.addListener([e|onSoll])
		haben.selectionModel.selectedItemProperty.addListener([e|onHaben])
		initDaten(0)
		soll.setPrefWidth(1000)
		haben.setPrefWidth(1000)
		soll.requestFocus
	}

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		var String parameter = parameter1
		if (stufe <= 0) {
			var max = get(FactoryService::haushaltService.holeMinMaxPerioden(serviceDaten))
			var dB = LocalDate::now
			dB = dB.withDayOfMonth(dB.lengthOfMonth)
			if (max !== null && max.datumBis !== null && max.datumBis.isBefore(dB)) {
				dB = max.datumBis
			}
			var dV = dB.withDayOfYear(1)
			if (max !== null && max.datumVon !== null && max.datumVon.isAfter(dV)) {
				dV = max.datumVon
			}
			if (Constant.KZBI_GV.equals(parameter)) {
				von.setValue(dV)
				bis.setValue(dB)
			} else if (Constant.KZBI_EROEFFNUNG.equals(parameter)) {
				von.setValue(dV)
				bis.setValue(dV)
			} else {
				von.setValue(dB)
				bis.setValue(dB)
			}
			if (Constant.KZBI_GV.equals(parameter)) {
				soll0.setText(Global.g("HH500.soll.GV"))
				haben0.setText(Global.g("HH500.haben.GV"))
			} else {
				soll0.setText(Global.g("HH500.soll.EB"))
				haben0.setText(Global.g("HH500.haben.EB"))
				von0.setText(Global.g("HH500.von.EB"))
				bis0.setVisible(false)
				bis.setVisible(false)
			}
		}
		if (stufe <= 1) {
			var LocalDate dV
			var LocalDate dB
			if (Constant.KZBI_GV.equals(parameter)) {
				dV = von.value
				dB = bis.value
			} else {
				dV = von.value
				dB = von.value
			}
			var liste = get(FactoryService::haushaltService.getBilanzZeilen(serviceDaten, parameter, dV, dB))
			var listeS = new ArrayList<HhBilanzSb>
			var listeH = new ArrayList<HhBilanzSb>
			var summeS = 0.0
			var summeH = 0.0
			if (liste !== null) {
				for (HhBilanzSb b : liste) {
					if (b.art > 0) {
						listeS.add(b)
						summeS += b.esumme
					} else {
						listeH.add(b)
						summeH += b.esumme
					}
				}
			}
			getItems(listeS, null, [a|new SollData(a)], sollData)
			getItems(listeH, null, [a|new SollData(a)], habenData)
			sollBetrag0.setText(Global.dblStr(summeS))
			habenBetrag0.setText(Global.dblStr(summeH))
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		soll.setItems(sollData)
		colKontoUid.setCellValueFactory([c|c.value.kontoUid])
		colName.setCellValueFactory([c|c.value.name])
		colBetrag.setCellValueFactory([c|c.value.betrag])
		initColumnBetrag(colBetrag)
		haben.setItems(habenData)
		colhKontoUid.setCellValueFactory([c|c.value.kontoUid])
		colhName.setCellValueFactory([c|c.value.name])
		colhBetrag.setCellValueFactory([c|c.value.betrag])
		initColumnBetrag(colhBetrag)
	}

	/** 
	 * Event für Aktuell.
	 */
	def private void onAktuell() {
		refreshTable(soll, 1)
		refreshTable(haben, 1)
	}

	/** 
	 * Event für Berechnen.
	 */
	@FXML def void onBerechnen() {

		val Task<Void> task = ([|
			var keine = true
			var weiter = 2
			var LocalDate v
			var ServiceErgebnis<String[]> r
			try {
				Jhh6.setLeftStatus2(Meldungen::HH060)
				if (mlBerechnen > 0) {
					v = von.value
					mlBerechnen = 0
				}
				while (weiter >= 2 && (r === null || r.ok)) {
					r = FactoryService::haushaltService.aktualisiereBilanz(serviceDaten, false, v)
					v = null
					if (r.ok) {
						var l = r.ergebnis
						if (Global.arrayLaenge(l) >= 1) {
							weiter = Global.strInt(l.get(0))
							if (weiter > 0) {
								keine = false
							}
						}
						if (Global.arrayLaenge(l) >= 2 && !Global.nes(l.get(1))) {
							Jhh6.setLeftStatus2(Meldungen::HH061(l.get(1)))
						}
					} else {
						get(r)
					}
				}
			} finally {
				if (keine) {
					mlBerechnen++
				} else {
					Platform::runLater([onVon])
				}
				if (r === null || r.ok) {
					Jhh6.setLeftStatus2("")
				}
			}
			null as Void
		] as Task<Void>)
		var th = new Thread(task)
		th.setDaemon(true)
		th.start
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
	 * Event für Drucken.
	 */
	@FXML def void onDrucken() {

		var d = new ArrayList<Object>
		d.add(parameter1)
		d.add(von.value)
		d.add(bis.value)
		starteFormular(HH510DruckenController, DialogAufrufEnum::OHNE, d)
	}

	/** 
	 * Event für Soll.
	 */
	@FXML def void onSollMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			starteBuchungen(getValue(soll, false))
		}
	}

	/** 
	 * Event für Haben.
	 * @FXML
	 */
	def void onHabenMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			starteBuchungen(getValue(haben, false))
		}
	}

	def private void starteBuchungen(HhBilanzSb bi) {

		if (bi !== null) {
			var v = von.value
			var b = bis.value
			if (Constant.KZBI_EROEFFNUNG.equals(parameter1)) {
				b = v.plusYears(1).minusDays(1)
			} else if (Constant.KZBI_SCHLUSS.equals(parameter1)) {
				b = v
				v = b.withDayOfYear(1)
			}
			starteFormular(HH400BuchungenController, DialogAufrufEnum::OHNE, v, b, bi)
		}
	}

	/** 
	 * Event für Von.
	 */
	@FXML def void onVon() {
		onAktuell
	}

	/** 
	 * Event für Bis.
	 */
	@FXML def void onBis() {
		onAktuell
	}

	/** 
	 * Event für Oben.
	 */
	@FXML def void onOben() {
		tauschen(true)
	}

	/** 
	 * Event für Unten.
	 */
	@FXML def void onUnten() {
		tauschen(false)
	}

	/** 
	 * Event für Soll.
	 */
	@FXML def void onSoll() {
		sollTabelle = true
	}

	/** 
	 * Event für Haben.
	 */
	@FXML def void onHaben() {
		sollTabelle = false
	}

	def private void tauschen(boolean oben) {

		var List<HhBilanzSb> l
		var r = 0
		var d = if(oben) -1 else 1
		if (sollTabelle) {
			r = soll.selectionModel.selectedIndex
			l = getAllValues(soll)
		} else {
			r = haben.selectionModel.selectedIndex
			l = getAllValues(haben)
		}
		if (0 <= r && r < l.size && 0 <= r + d && r + d < l.size) {
			var k = l.get(r)
			var k2 = l.get(r + d)
			get(FactoryService::haushaltService.tauscheKontoSortierung(serviceDaten, k.kontoUid, k2.kontoUid))
			var r2 = 0
			if (sollTabelle) {
				r = r + d
				r2 = haben.selectionModel.selectedIndex
			} else {
				r2 = r + d
				r = soll.selectionModel.selectedIndex
			}
			onAktuell
			if (r >= 0) {
				soll.selectionModel.select(r)
			}
			if (r2 >= 0) {
				haben.selectionModel.select(r2)
			}
		}
	}
}
