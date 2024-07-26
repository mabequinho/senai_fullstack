import { Routes } from "@angular/router";
import { InicioComponent } from "./inicio/inicio.component";
import { LoginComponent } from "./login/login.component";

export const routes: Routes = [
  { path: "inicio", component: InicioComponent },
  { path: "login", component: LoginComponent },
  { path: "", redirectTo: "/inicio", pathMatch: "full" },
];
