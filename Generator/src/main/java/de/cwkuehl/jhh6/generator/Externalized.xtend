package de.cwkuehl.jhh6.generator

import java.io.ByteArrayInputStream
import java.text.DateFormat
import java.text.Format
import java.text.MessageFormat
import java.text.NumberFormat
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneId
import java.util.Date
import java.util.List
import java.util.Locale
import java.util.MissingResourceException
import java.util.ResourceBundle
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationContext
import org.eclipse.xtend.lib.macro.CodeGenerationParticipant
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference

@Active(ExternalizedProcessor)
annotation Externalized {
}

class ExternalizedProcessor extends AbstractClassProcessor implements CodeGenerationParticipant<ClassDeclaration> {

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {

		for (field : annotatedClass.declaredFields) {
			val initializer = field.initializerAsString
			val msgFormat = try {
					new MessageFormat(initializer)
				} catch (IllegalArgumentException e) {
					field.initializer.addError('''invalid format: «e.message»''')
					new MessageFormat("")
				}
			val formats = msgFormat.formatsByArgumentIndex
			if (msgFormat.formats.length != formats.length) {
				field.initializer.addWarning('''Unused placeholders («msgFormat.formats.length», «formats.length»).''')
			}

			annotatedClass.addMethod(field.simpleName) [
				formats.forEach [ format, idx |
					addParameter("arg" + idx, format.formatType(context))
				]
				returnType = string
				docComment = initializer
				static = true
				val params = parameters
				body = [
					// «FOR f : formats.indexed»
					// «IF f.v.formatNullable(context) »
					// if (arg«f.index» == null)
					// return "";
					// «ENDIF»
					// «ENDFOR»
					'''
						try {
							String msg = BUNDLE.getString("«field.simpleName»");
							«IF formats.length > 0»
								msg = «toJavaCode(MessageFormat.newTypeReference)».format(msg, «params.map["c(" + simpleName + ")"].join(", ")»);
							«ENDIF»
							return msg;
						} catch («toJavaCode(MissingResourceException.newTypeReference)» e) {
							return "«initializer»";
						}
					'''
				]
				primarySourceElement = field
			]
		}
		annotatedClass.declaredFields.forEach[remove]

		annotatedClass.addMethod("c") [
			addParameter("p", string)
			returnType = string
			docComment = "Convert."
			static = true
			body = '''return p == null ? "" : p;'''
		]

		// annotatedClass.addMethod("c") [
		// addParameter("p", primitiveInt)
		// returnType = primitiveInt
		// docComment = "Convert."
		// static = true
		// body = '''return p;'''
		// ]
		annotatedClass.addMethod("c") [
			addParameter("p", primitiveDouble)
			returnType = primitiveDouble
			docComment = "Convert."
			static = true
			body = '''return p;'''
		]

		annotatedClass.addMethod("c") [
			addParameter("p", LocalDateTime.newTypeReference)
			returnType = Date.newTypeReference
			docComment = "Convert."
			static = true
			body = [
				'''
					// return «toJavaCode(LocalDateTime.newTypeReference)».ofInstant(«toJavaCode(Instant.newTypeReference)».ofEpochMilli(p.getTime()), «toJavaCode(ZoneId.newTypeReference)».systemDefault());
					if (p == null)
						return new Date();
					return «toJavaCode(Date.newTypeReference)».from(p.atZone(«toJavaCode(ZoneId.newTypeReference)».systemDefault()).toInstant());
				'''
			]
		]

		annotatedClass.addMethod("clearCache") [
			addParameter("l", Locale.newTypeReference)
			docComment = "Clear Cache and reload bundle."
			static = true
			body = [
				'''
					BUNDLE.clearCache();
					BUNDLE = ResourceBundle.getBundle("«annotatedClass.qualifiedName»", l);
				'''
			]
		]

		// private static final ResourceBundle RESOURCE_BUNDLE = ResourceBundle.getBundle(BUNDLE_NAME);
		annotatedClass.addField("BUNDLE") [
			static = true
			final = false
			type = ResourceBundle.newTypeReference
			initializer = ['''ResourceBundle.getBundle("«annotatedClass.qualifiedName»")''']
			primarySourceElement = annotatedClass
		]

	}

	override doGenerateCode(List<? extends ClassDeclaration> annotatedSourceElements,
		extension CodeGenerationContext context) {

		for (clazz : annotatedSourceElements) {
			val filePath = clazz.compilationUnit.filePath
			val file = filePath.projectFolder.append('/src/main/resources').append(
				clazz.qualifiedName.replace('.', '/') + ".properties")
			// #TargetFolder = «filePath.targetFolder»
			// #ProjectFolder = «filePath.projectFolder»
			var s = '''
				«FOR field : clazz.declaredFields»
					«field.simpleName» = «field.initializerAsString»
				«ENDFOR»
			'''
			// file.contents = s
			file.contentsAsStream = new ByteArrayInputStream(s.getBytes("ISO-8859-1"))
		}
	}

	def private String getInitializerAsString(FieldDeclaration f) {

		var string = f.initializer?.toString
		if (string === null)
			return "" // "empty string"
		string = string.substring(1, string.length - 1)
		var s = new StringBuilder
		var anfang = true
		val char leer = ' '
		for (c : string.toCharArray) {
			if (anfang && leer == c)
				s.append("\\u0020")
			else {
				s.append(c)
				anfang = false
			}
		}
		return s.toString
	}

	def TypeReference formatType(Format format, extension TransformationContext context) {

		switch format {
			NumberFormat: primitiveDouble
			DateFormat: LocalDateTime.newTypeReference
			default: string
		}
	}

	def boolean formatNullable(Format format, extension TransformationContext context) {

		switch format {
			NumberFormat: false
			default: true
		}
	}
}
