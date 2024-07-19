import { Component } from "@angular/core";
import { RouterOutlet } from "@angular/router";
import { MenusComponent } from "./menus/menus.component";
import { GridComponent } from "./grid/grid.component";

@Component({
  selector: "app-root",
  standalone: true,
  imports: [RouterOutlet, MenusComponent, GridComponent],
  templateUrl: "./app.component.html",
  styleUrl: "./app.component.css",
})
export class AppComponent {
  title = "lustore";
}
