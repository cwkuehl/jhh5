package de.cwkuehl.jhh6.server.fop.impl

import de.cwkuehl.jhh6.api.dto.AdPersonSitzAdresse
import de.cwkuehl.jhh6.api.dto.HhBilanzDruck
import de.cwkuehl.jhh6.api.dto.HhBilanzSb
import de.cwkuehl.jhh6.api.dto.HhBuchungLang
import de.cwkuehl.jhh6.api.dto.HhKonto
import de.cwkuehl.jhh6.server.fop.doc.FoAdressenliste
import de.cwkuehl.jhh6.server.fop.doc.FoJahresbericht
import de.cwkuehl.jhh6.server.fop.doc.FoKassenbericht
import java.io.ByteArrayOutputStream
import java.time.LocalDate
import java.util.List

/** 
 * Diese Klasse die Erzeugung aller möglichen Dokumente bereit.
 */
class JhhFopDokumentImpl {

	FoGeneratorDocumentMulti multiDoc = null
	JhhFop jhhFop = null

	/** 
	 * Konstruktor mit Initialisierung.
	 * @param jhhFop
	 */
	new(JhhFop jhhFop) {
		this.jhhFop = jhhFop
		multiDoc = new FoGeneratorDocumentMulti
	}

	/** 
	 * {@inheritDoc}
	 * @see de.cwkuehl.jhh.server.service.fop.JhhFopDokument#erzeugePdf()
	 */
	def byte[] erzeugePdf() {
		if (multiDoc.getAnzahl <= 0) {
			throw new JhhFopException("Es ist kein Ausgangsdokument hinzugefügt worden.")
		}
		var ByteArrayOutputStream bs = new ByteArrayOutputStream
		// multiDoc.writeDocument("/home/wolfgang/temp/test.fo");
		jhhFop.machPdf(multiDoc.getSource, null, null, bs)
		return bs.toByteArray
	}

	/** 
	 * {@inheritDoc}
	 * @see de.cwkuehl.jhh.server.service.fop.JhhFopDokument#erzeugeRtf()
	 */
	def byte[] erzeugeRtf() {
		if (multiDoc.getAnzahl <= 0) {
			throw new JhhFopException("Es ist kein Ausgangsdokument hinzugefügt worden.")
		}
		var ByteArrayOutputStream bs = new ByteArrayOutputStream
		jhhFop.machRtf(multiDoc.getSource, null, null, bs)
		return bs.toByteArray
	}

	/** 
	 * {@inheritDoc}
	 * @see de.cwkuehl.jhh.server.service.fop.JhhFopDokument#addAdressenliste(boolean, String, java.util.List)
	 */
	def void addAdressenliste(boolean reset, String ueberschrift, List<AdPersonSitzAdresse> liste) {
		var FoAdressenliste doc = new FoAdressenliste
		multiDoc.add(doc, reset)
		doc.generate(ueberschrift, liste)
	}

// public void addNachfahrenliste(boolean reset, String ueberschrift, String untertitel, List<SbPerson> liste) {
//
// FoNachfahrenliste doc = new FoNachfahrenliste;
// multiDoc.add(doc, reset);
// doc.generate(ueberschrift, untertitel, liste);
// }
//
// public void addVorfahrenliste(boolean reset, String ueberschrift, String untertitel, List<SbPerson> liste) {
//
// FoNachfahrenliste doc = new FoNachfahrenliste;
// multiDoc.add(doc, reset);
// doc.generate(ueberschrift, untertitel, liste);
// }
	def void addJahresbericht(boolean reset, String ueberschrift, List<HhBilanzDruck> ebListe,
		List<HhBilanzDruck> gvListe, List<HhBilanzDruck> sbListe) {

		var doc = new FoJahresbericht
		multiDoc.add(doc, reset)
		doc.generate(ueberschrift, ebListe, gvListe, sbListe)
	}

	def void addKassenbericht(boolean reset, boolean monatlich, String ueberschrift, LocalDate dVon, LocalDate dBis,
		String titel, String periode, double vortrag, double einnahmen, double ausgaben, double saldo,
		List<HhKonto> kListe, List<HhBilanzSb> gvListe, List<HhBuchungLang> bListeE, List<HhBuchungLang> bListeA,
		List<HhBuchungLang> bListe) {

		var doc = new FoKassenbericht
		multiDoc.add(doc, reset)
		doc.generate(monatlich, ueberschrift, dVon, dBis, titel, vortrag, einnahmen, ausgaben, saldo, kListe, gvListe,
			bListeE, bListeA, bListe)
	}

// public void addRechnung(boolean reset, HpRechnung rechnung, HpPatient patient, HpPatient patientAdresse,
// LocalDate zahldatum, List<HpBehandlungDruck> behandlungen, Map<String, String> einstellungen) {
//
// FoRechnung doc = new FoRechnung;
// multiDoc.add(doc, reset);
// doc.generate(rechnung, patient, patientAdresse, zahldatum, behandlungen, einstellungen);
// }
//
// public void addAbrechnung(boolean reset, FoHaus haus) {
//
// FoAbrechnung doc = new FoAbrechnung;
// multiDoc.add(doc, reset);
// doc.generate(haus);
// }
//
// public void addMieterliste(boolean reset, String ueberschrift, LocalDate von, LocalDate bis, List<FoHaus> haeuser) {
//
// FoMieterliste doc = new FoMieterliste;
// multiDoc.add(doc, reset);
// doc.generate(ueberschrift, von, bis, haeuser);
// }
//
// public void addPatientenakte(boolean reset, LocalDate von, LocalDate bis, HpPatient patient,
// List<HpBehandlungDruck> behandlungen) {
//
// FoPatientenakte doc = new FoPatientenakte;
// multiDoc.add(doc, reset);
// doc.generate(von, bis, patient, behandlungen);
// }
//
// public void addMessdienerordnung(boolean reset, LocalDate von, LocalDate bis, List<MoGottesdienstLang> einteilungen) {
//
// FoMessdienerordnung doc = new FoMessdienerordnung;
// multiDoc.add(doc, reset);
// doc.generate(von, bis, einteilungen);
// }
}