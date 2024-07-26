import { Component } from "@angular/core";
import { NgbCarouselModule } from "@ng-bootstrap/ng-bootstrap";

@Component({
  selector: "app-inicio",
  standalone: true,
  imports: [NgbCarouselModule],
  templateUrl: "./inicio.component.html",
  styleUrl: "./inicio.component.css",
})
export class InicioComponent {
  images = [
    "/assets/img/img_02.webp",
    "/assets/img/img_05.webp",
    "/assets/img/img_07.webp",
  ];
}
