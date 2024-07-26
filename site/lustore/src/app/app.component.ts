import { Component } from "@angular/core";
import { RouterOutlet } from "@angular/router";
import { MenuComponent } from "./menu/menu.component";
import { InicioComponent } from "./inicio/inicio.component";

@Component({
  selector: "app-root",
  standalone: true,
  imports: [RouterOutlet, MenuComponent, InicioComponent],
  templateUrl: "./app.component.html",
  styleUrl: "./app.component.css",
})
export class AppComponent {
  title = "lustore";
}
