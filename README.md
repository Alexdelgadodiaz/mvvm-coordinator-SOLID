
# Proyecto mvvm-coordinator-SOLID

Arquitectura modular basada en principios SOLID, patrones de diseño clásicos y buenas prácticas modernas en Swift.

---

## Tecnologías

- Swift 6
- Swift Concurrency (async/await)
- SwiftUI

---

## Patrones de Diseño Implementados

- **MVVM**: Separación estricta View → ViewModel.
- **Repository Pattern**: Abstracción de fuentes de datos (API, Cache).
- **Dependency Injection**: Constructor Injection, no Service Locator.
- **Protocol-Oriented Programming**: Inversión de dependencias.
- **Singleton Controlado**: Reuso de instancias sin comprometer testabilidad.
- **Coordinator Pattern**: Flujo de navegación desacoplado.
- **Decorator Pattern**: Metainformación en caché (expiración).

---

## Estructura de Carpetas

```
├── Presentation
│   ├── Views
│   ├── ViewModels
├── Domain
│   ├── UseCases
│   ├── Repositories
│   ├── Models
├── Infrastructure
│   ├── API
│   ├── Cache
├── Coordinators
├── Resources
```

---

## Características de Implementación

- **Cache híbrida**: NSCache + FileManager, clave SHA256.
- **Prefetching y Paginación**: Carga anticipada bajo demanda.
- **Debounce en Búsquedas**: 0.5s para optimización de llamadas.
- **Validación de respuestas**: HTTP Status Code + estructura esperada.
- **Cancelación de tareas**: `Task.isCancelled` durante operaciones async.
- **Inmutabilidad**: Modelos como `struct` con propiedades `let`.
- **Localizacion**: En español e inglés. El servidor devuelve textos en inglés, se ha localizado la fecha.

---

## Flujo Principal

### Carga de Episodios

```plaintext
EpisodesListView → EpisodesListViewModel → DefaultEpisodeUseCase → DefaultEpisodeRepository → DefaultCharacterAPIManager
```

### Navegación

```plaintext
EpisodesListView → AppCoordinator → EpisodeDetailView
```

---

## Buenas Prácticas Aplicadas

- Separación estricta de responsabilidades.
- Modularización por contexto funcional.
- Documentación con `// MARK:`.
- Testabilidad en todos los niveles.
- Uso de genéricos seguros en almacenamiento en caché.

---

## Notas

- No se abusa de Singletons.
- No se acoplan Views directamente a servicios.
- No se mezclan capas (Presentation, Domain, Infrastructure).

---

## Requisitos para Contribuir

- Conocer arquitecturas limpias (Clean Architecture).
- Entender principios SOLID y programación reactiva.
- Mantener la coherencia de estilo y convenciones existentes.

---

## Contacto

Para cualquier duda o propuesta de mejora, abrir un Pull Request o Issue.


