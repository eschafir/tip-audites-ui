package audites.AuditorWindows

import audites.AuditorWindow
import audites.appModel.AuditorAppModel
import audites.appModel.NewRevisionAppModel
import audites.domain.Department
import org.uqbar.arena.bindings.DateTransformer
import org.uqbar.arena.bindings.PropertyAdapter
import org.uqbar.arena.layout.ColumnLayout
import org.uqbar.arena.layout.VerticalLayout
import org.uqbar.arena.widgets.Button
import org.uqbar.arena.widgets.GroupPanel
import org.uqbar.arena.widgets.Label
import org.uqbar.arena.widgets.Panel
import org.uqbar.arena.widgets.Selector
import org.uqbar.arena.widgets.TextBox
import org.uqbar.arena.windows.SimpleWindow
import org.uqbar.arena.windows.WindowOwner

import static extension org.uqbar.arena.xtend.ArenaXtendExtensions.*
import audites.domain.Requirement

class NewRevisionWindow extends SimpleWindow<NewRevisionAppModel> {

	new(WindowOwner parent, NewRevisionAppModel model) {
		super(parent, model)
		this.taskDescription = "Complete la informacion necesaria para la nueva revision"
	}

	override protected addActions(Panel actionsPanel) {

		new Button(actionsPanel) => [
			caption = "Aceptar"
			onClick[|
				this.modelObject.createRevison
				this.close
				new AuditorWindow(this, new AuditorAppModel(this.modelObject.userLoged)).open
			]
		]

		new Button(actionsPanel) => [
			caption = "Atras"
			onClick[|
				this.close
				new AuditorWindow(this, new AuditorAppModel(this.modelObject.userLoged)).open
			]
		]
	}

	override protected createFormPanel(Panel mainPanel) {
		this.title = "Audites"
		val principalPanel = new Panel(mainPanel)
		principalPanel.layout = new ColumnLayout(2)

		createRevisionPanel(principalPanel)
		createRequirementsPanel(principalPanel)

	}

	def createRevisionPanel(Panel panel) {
		val revisionPanel = new GroupPanel(panel)
		revisionPanel.title = "Nueva revision"

		val nameRevision = new Panel(revisionPanel)
		nameRevision.layout = new VerticalLayout

		new Label(nameRevision).text = "Nombre"
		new TextBox(nameRevision) => [
			value <=> "revision.name"
			width = 200
		]

		val departmentRevision = new Panel(revisionPanel)
		departmentRevision.layout = new VerticalLayout

		new Label(departmentRevision).text = "Departamento"
		new Selector(departmentRevision) => [
			width = 185
			allowNull(false)
			value <=> "selectedDepartment"
			(items.bindToProperty("departments")).adapter = new PropertyAdapter(Department, "name")
		]

		val description = new Panel(revisionPanel)
		new Label(description).text = "Comentarios"
		new TextBox(description) => [
			multiLine = true
			height = 200
			width = 200
			value <=> "revision.description"
		]

		val dates = new Panel(revisionPanel)
		new TextBox(dates) => [
			value.bindToProperty("revision.endDate").transformer = new DateTransformer
		]

	}

	def createRequirementsPanel(Panel panel) {
		val reqPanel = new GroupPanel(panel)
		reqPanel.title = "Requerimientos"

		new Label(reqPanel) => [
			value <=> "revision.name"
			fontSize = 30
		]

		new Button(reqPanel) => [
			caption = "Agregar..."
			onClick[|
				new NewRequirementWindow(this, new Requirement).open
			]
		]
	}

}