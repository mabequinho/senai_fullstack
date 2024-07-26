import { Component } from "@angular/core";
import { MatGridListModule } from "@angular/material/grid-list";
import { MatButtonModule } from "@angular/material/button";
import { MatCardModule } from "@angular/material/card";

@Component({
  selector: "app-gridprodutos",
  standalone: true,
  imports: [MatGridListModule, MatButtonModule, MatCardModule],
  templateUrl: "./gridprodutos.component.html",
  styleUrl: "./gridprodutos.component.css",
})
export class GridprodutosComponent {}
