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
  images = [944, 1011, 984].map((n) => `https://picsum.photos/id/${n}/900/500`);
}
