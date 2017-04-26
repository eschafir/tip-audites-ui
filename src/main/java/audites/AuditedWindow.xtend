package audites

import audites.AuditedWindows.AttendRevisionWindow
import audites.AuditorWindows.CheckRevisionWindow
import audites.TemplatesWindows.DefaultWindow
import audites.appModel.AuditedAppModel
import audites.appModel.MainApplicationAppModel
import audites.domain.Revision
import audites.domain.User
import java.awt.Color
import java.util.Date
import javax.swing.JOptionPane
import org.uqbar.arena.bindings.PropertyAdapter
import org.uqbar.arena.graphics.Image
import org.uqbar.arena.layout.HorizontalLayout
import org.uqbar.arena.widgets.Button
import org.uqbar.arena.widgets.GroupPanel
import org.uqbar.arena.widgets.Label
import org.uqbar.arena.widgets.Panel
import org.uqbar.arena.widgets.Selector
import org.uqbar.arena.widgets.TextBox
import org.uqbar.arena.widgets.tables.Column
import org.uqbar.arena.widgets.tables.Table
import org.uqbar.arena.windows.WindowOwner

import static extension org.uqbar.arena.xtend.ArenaXtendExtensions.*

class AuditedWindow extends DefaultWindow<AuditedAppModel> {

	new(WindowOwner parent, AuditedAppModel model) {
		super(parent, model)
		modelObject.search
	}

	override createButtonPanels(Panel actionsPanel) {
		new Button(actionsPanel) => [
			caption = "Atras"
			onClick[|
				this.close
				new MainApplicationWindows(this, new MainApplicationAppModel(this.modelObject.userLoged)).open
			]
		]
	}

	override createWindowToFormPanel(Panel mainPanel) {
		val imagePanel = new Panel(mainPanel)

		new Label(imagePanel) => [
			bindImageToProperty("pathImagen", [ imagePath |
				new Image(imagePath)
			])
		]

		searchBar(mainPanel)
		revisionList(mainPanel)
		createRevisionButtons(mainPanel)
	}

	def searchBar(Panel panel) {
		val searchPanel = new GroupPanel(panel) => [
			title = ""
			layout = new HorizontalLayout
		]

		new Label(searchPanel) => [
			text = "Buscar: "
		]

		new TextBox(searchPanel) => [
			value <=> "revisionSearch"
			width = 200
		]
	}

	protected def revisionList(Panel mainPanel) {
		val principal = new Panel(mainPanel)
		principal.layout = new HorizontalLayout

		val tablePanel = new GroupPanel(principal) => [title = ""]
		new Label(tablePanel) => [
			text = "Revisiones asignadas"
			fontSize = 13
		]

		val table = new Table<Revision>(tablePanel, typeof(Revision)) => [
			items <=> "results"
			value <=> "revisionSelected"
			numberVisibleRows = 10
		]

		resultsTableGrid(table)
		revisionAsign(tablePanel)
	}

	protected def createRevisionButtons(Panel mainPanel) {

		val panel = new Panel(mainPanel)

		val buttonPanel = new GroupPanel(panel) => [
			title = ""
			layout = new HorizontalLayout
		]
		new Button(buttonPanel) => [
			caption = "Atender"
			fontSize = 10
			width = 140
			height = 40
			enabled <=> "revisionIsSelectedAudited"
			onClick[|
				this.close
				new AttendRevisionWindow(this, this.modelObject.revisionSelected, this.modelObject.userLoged).open
			]
		]

		new Button(buttonPanel) => [
			caption = "Ver"
			fontSize = 10
			width = 140
			height = 40
			enabled <=> "revisionIsDerived"
			onClick[|
				new CheckRevisionWindow(this, this.modelObject.revisionSelected, this.modelObject.userLoged).open
			]
		]

		buttonApprove(buttonPanel)
	}

	def resultsTableGrid(Table<Revision> table) {
		new Column<Revision>(table) => [
			title = "Nombre"
			bindContentsToProperty("name")
		]

		new Column<Revision>(table) => [
			title = "Departamento"
			bindContentsToProperty("responsable.name")
		]

		new Column<Revision>(table) => [
			title = "Creada"
			bindContentsToProperty("initDate").transformer = [Date date|modelObject.formatDate(date)]
		]

		new Column<Revision>(table) => [
			title = "Finaliza"
			bindContentsToProperty("endDate").transformer = [Date date|modelObject.formatDate(date)]
		/**
		 * Poner un transforme de color para indicar si venció o no.
		 */
		]

		if (modelObject.userLoged.maximumResponsable(this.modelObject.revisionSelected.responsable)) {
			new Column<Revision>(table) => [
				title = "Asignado a"
				bindContentsToProperty("attendant.name")
			]
		}

		new Column<Revision>(table) => [
			title = "Progreso (%)"
			bindContentsToProperty("average")
			bindBackground("isCompleted").transformer = [Boolean completed|if(completed) Color.GREEN else Color.ORANGE]
		]
	}

	def revisionAsign(Panel panel) {
		if (!this.modelObject.userLoged.revisions.empty &&
			this.modelObject.userLoged.maximumResponsable(this.modelObject.revisionSelected.responsable)) {
			val revisionDetailPanel = new Panel(panel)
			validateMaximumAuthority(revisionDetailPanel)
		}
	}

	def validateMaximumAuthority(Panel mainPanel) {
		val panel = new Panel(mainPanel).layout = new HorizontalLayout
		new Label(panel).text = "Asignar a:"
		new Selector<User>(panel) => [
			width = 250
			allowNull(false)
			enabled <=> "isAsignedToAuthor"
			value <=> "selectedUser"
			(items.bindToProperty("obtainUsers")).adapter = new PropertyAdapter(Revision, "name")
		]
	}

	def buttonApprove(Panel mainPanel) {
		if (!this.modelObject.userLoged.revisions.empty &&
			this.modelObject.userLoged.maximumResponsable(this.modelObject.revisionSelected.responsable)) {
			new Button(mainPanel) => [
				caption = "Aprobar"
				fontSize = 10
				width = 140
				height = 40
				enabled <=> "revisionFinished"
				onClick[|
					openConfirmationDialog
				]
			]
		}
	}

	def openConfirmationDialog() {
		val dialogButton = JOptionPane.YES_NO_OPTION;
		val dialogAnswer = JOptionPane.showConfirmDialog(null,
			"La revision '" + this.modelObject.revisionSelected.name + "' será derivada a " +
				this.modelObject.revisionSelected.author.name + " para su revision final." + "\r\n" +
				"¿Desea continuar?", "question", dialogButton);

			if (dialogAnswer == JOptionPane.YES_OPTION) {
				this.modelObject.deriveToAuthor
			}
		}
	}
	