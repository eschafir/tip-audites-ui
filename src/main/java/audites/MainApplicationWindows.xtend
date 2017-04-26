package audites

import audites.Login.LoginWindows
import audites.TemplatesWindows.DefaultWindow
import audites.appModel.AdminPanelAppModel
import audites.appModel.AuditedAppModel
import audites.appModel.MainApplicationAppModel
import audites.domain.Role
import java.util.HashMap
import org.uqbar.arena.graphics.Image
import org.uqbar.arena.widgets.Button
import org.uqbar.arena.widgets.Label
import org.uqbar.arena.widgets.Panel
import org.uqbar.arena.windows.WindowOwner

class MainApplicationWindows extends DefaultWindow<MainApplicationAppModel> {

	new(WindowOwner parent, MainApplicationAppModel model) {
		super(parent, model)
	}

	override createButtonPanels(Panel mainPanel) {
		new Button(mainPanel) => [
			caption = "Logout"
			onClick[
				this.modelObject.writeLog(this.modelObject.userLoged)
				this.close
				new LoginWindows(this).open
			]
		]
	}

	override createWindowToFormPanel(Panel mainPanel) {

		putCompanyLogo(mainPanel)

		val panel = new Panel(mainPanel)
		new Label(panel).text = "Menues"
		var botonera = new HashMap

		botonera.put("Administrator", [|
			new Button(panel) => [
				caption = "Administracion"
				onClick[|
					this.close
					new AdminWindow(this, new AdminPanelAppModel(this.modelObject.userLoged)).open
				]
			]
		])
		botonera.put(
			"Auditor",
			[|
				new Button(panel) => [
					caption = "Auditor"
					width = 200
					onClick[|
						this.close
						new AuditorWindow(this, this.modelObject.userLoged).open
					]
				]

			]
		)
		botonera.put(
			"Audited",
			[|
				new Button(panel) => [
					caption = "Revisiones"
					width = 200
					onClick[|
						this.close
						new AuditedWindow(this, new AuditedAppModel(this.modelObject.userLoged)).open
					]

				]
			]
		)

		println(this.modelObject.userLoged.roles)
		for (Role r : this.modelObject.userLoged.roles) {
			botonera.get(r.name).apply
		}
	}

	protected def putCompanyLogo(Panel mainPanel) {
		val imagePanel = new Panel(mainPanel)

		new Label(imagePanel) => [
			bindImageToProperty("pathImagen", [ imagePath |
				new Image(imagePath)
			])
		]
	}
}
