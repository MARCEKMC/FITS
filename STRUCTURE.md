# FITS - Estructura del Proyecto

## Arquitectura MVVM por Módulos

El proyecto FITS ha sido reorganizado siguiendo el patrón MVVM (Model-View-ViewModel) agrupado por módulos funcionales para mejorar la mantenibilidad, escalabilidad y claridad del código.

## Estructura de Carpetas

```
lib/
├── app.dart                 # Configuración principal de la aplicación
├── main.dart               # Punto de entrada de la aplicación
├── core/                   # Funcionalidades centrales
│   ├── navigation/         # Navegación y rutas
│   ├── theme/             # Temas y estilos
│   └── utils/             # Utilidades generales
├── data/                   # Capa de datos
│   ├── datasources/       # Fuentes de datos (APIs, local storage)
│   ├── models/            # Modelos de datos
│   ├── repositories/      # Repositorios
│   ├── services/          # Servicios
│   └── utils/             # Utilidades de datos
├── modules/                # Módulos organizados por funcionalidad
│   ├── auth/              # Autenticación y autorización
│   │   ├── screens/       # Pantallas de autenticación
│   │   ├── viewmodels/    # ViewModels de autenticación
│   │   ├── widgets/       # Widgets específicos de auth
│   │   └── index.dart     # Exports del módulo
│   ├── efficiency/        # Productividad (notas, tareas, horarios)
│   │   ├── screens/       # Pantallas de productividad
│   │   ├── viewmodels/    # ViewModels de efficiency
│   │   ├── widgets/       # Widgets de efficiency (incluyendo notas)
│   │   └── index.dart     # Exports del módulo
│   ├── health/            # Salud y fitness
│   │   ├── screens/       # Pantallas de salud
│   │   ├── viewmodels/    # ViewModels de salud
│   │   ├── widgets/       # Widgets de salud
│   │   └── index.dart     # Exports del módulo
│   ├── fitsi/             # Chat bot FITSI
│   │   ├── viewmodels/    # ViewModels de FITSI
│   │   ├── widgets/       # Widgets de FITSI
│   │   └── index.dart     # Exports del módulo
│   └── profile/           # Perfil de usuario
│       ├── screens/       # Pantallas de perfil
│       ├── viewmodels/    # ViewModels de perfil
│       ├── widgets/       # Widgets de perfil
│       └── index.dart     # Exports del módulo
├── shared/                 # Componentes compartidos entre módulos
│   ├── viewmodels/        # ViewModels compartidos
│   ├── widgets/           # Widgets reutilizables
│   └── index.dart         # Exports compartidos
└── ui/                     # UI que no pertenece a módulos específicos
    ├── screens/           # Pantallas generales (home, main)
    └── widgets/           # Widgets generales
```

## Principios de Organización

### 1. **Separación por Módulos**
Cada módulo representa una funcionalidad principal de la aplicación:
- **auth**: Manejo de autenticación, login, registro
- **efficiency**: Productividad, notas, tareas, horarios, estadísticas
- **health**: Salud, ejercicios, alimentación, agua
- **fitsi**: Chat bot inteligente
- **profile**: Perfil de usuario y configuraciones

### 2. **Estructura MVVM por Módulo**
Cada módulo contiene:
- **screens/**: Pantallas (Views) del módulo
- **viewmodels/**: Lógica de presentación y estado
- **widgets/**: Componentes de UI específicos del módulo
- **index.dart**: Archivo de exports para facilitar imports

### 3. **Componentes Compartidos**
- **shared/**: Contiene ViewModels y widgets que son utilizados por múltiples módulos
- **core/**: Funcionalidades fundamentales de la aplicación
- **data/**: Capa de datos independiente de la UI

## Cambios Realizados

### Reorganización de Archivos
1. **Notas movidas a Efficiency**: Los widgets de notas (`ui/widgets/notes/`) se movieron al módulo `efficiency` ya que forman parte de las funcionalidades de productividad.

2. **ViewModels agrupados**: Los ViewModels se distribuyeron entre los módulos correspondientes:
   - `notes_viewmodel.dart` → `modules/efficiency/viewmodels/`
   - `health_viewmodel.dart` → `modules/health/viewmodels/`
   - `auth_viewmodel.dart` → `modules/auth/viewmodels/`
   - etc.

3. **Screens organizados**: Las pantallas se movieron a sus módulos correspondientes.

### Actualización de Imports
- Todos los imports se actualizaron para reflejar la nueva estructura
- Se crearon archivos `index.dart` en cada módulo para facilitar los imports
- Se eliminaron carpetas vacías y archivos obsoletos

## Beneficios de la Nueva Estructura

1. **Mejor Mantenibilidad**: Cada módulo es independiente y fácil de mantener
2. **Escalabilidad**: Nuevas funcionalidades pueden agregarse como nuevos módulos
3. **Reutilización**: Componentes compartidos están claramente identificados
4. **Claridad**: La estructura refleja la arquitectura de la aplicación
5. **Separación de Responsabilidades**: Cada capa tiene una responsabilidad específica

## Guía de Uso

### Para agregar nueva funcionalidad:
1. Determinar a qué módulo pertenece
2. Crear los archivos en las carpetas correspondientes (screens/, widgets/, viewmodels/)
3. Actualizar el archivo `index.dart` del módulo si es necesario

### Para imports:
```dart
// Import de un módulo completo
import 'package:fits/modules/efficiency/index.dart';

// Import específico
import 'package:fits/modules/efficiency/viewmodels/notes_viewmodel.dart';

// Import compartido
import 'package:fits/shared/viewmodels/selected_date_viewmodel.dart';
```
