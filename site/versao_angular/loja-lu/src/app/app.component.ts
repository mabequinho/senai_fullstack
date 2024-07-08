import { Component } from "@angular/core";
import { RouterOutlet } from "@angular/router";
import { NavComponent } from "./layout/nav/nav.component";
import { GridComponent } from "./layout/grid/grid.component";

@Component({
  selector: "app-root",
  standalone: true,
  imports: [RouterOutlet, NavComponent, GridComponent],
  templateUrl: "./app.component.html",
  styleUrl: "./app.component.scss",
})
export class AppComponent {
  title = "Cartridge Store";
}
