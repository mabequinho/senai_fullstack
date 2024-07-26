import { Component } from "@angular/core";
import {
  NgbCarouselModule,
  NgbCarouselConfig,
} from "@ng-bootstrap/ng-bootstrap";

@Component({
  selector: "app-inicio",
  standalone: true,
  imports: [NgbCarouselModule],
  templateUrl: "./inicio.component.html",
  styleUrl: "./inicio.component.css",
  providers: [NgbCarouselConfig], // add NgbCarouselConfig to the component providers
})
export class InicioComponent {
  showNavigationArrows = false;
  showNavigationIndicators = false;
  images = [
    "/assets/img/banner01.webp",
    "/assets/img/banner02.webp",
    "/assets/img/banner03.webp",
  ];
  constructor(config: NgbCarouselConfig) {
    // customize default values of carousels used by this component tree
    config.interval = 1600;
    config.showNavigationArrows = false;
    config.showNavigationIndicators = false;
  }
}
