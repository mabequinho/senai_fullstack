import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GridprodutosComponent } from './gridprodutos.component';

describe('GridprodutosComponent', () => {
  let component: GridprodutosComponent;
  let fixture: ComponentFixture<GridprodutosComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GridprodutosComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(GridprodutosComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
