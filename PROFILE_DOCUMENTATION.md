# Configuración de la Pantalla de Perfil

## Descripción
Se ha implementado una pantalla de perfil completa con diseño minimalista y elegante que incluye dos pestañas principales: **Perfil** y **Estadísticas**.

## Funcionalidades Implementadas

### 1. Pestaña de Perfil
- **Navegación por pestañas**: Interfaz deslizable entre Perfil y Estadísticas
- **Visualización de datos del usuario**:
  - Avatar circular (placeholder)
  - Nombre completo
  - Nombre de usuario
  - Edad (calculada automáticamente)
  
- **Campos editables**:
  - ✅ Nombres
  - ✅ Apellidos  
  - ✅ Género (selector dropdown)
  - ✅ Fecha de nacimiento (selector de fecha)
  - ✅ Región (selector dropdown con países hispanohablantes)
  - ✅ Idioma (selector dropdown)
  - ✅ Nivel de experiencia (Básico/Intermedio/Avanzado)

- **Campos bloqueados** (solo visualización):
  - 🔒 Nombre de usuario
  - 🔒 Correo electrónico

- **Validación y guardado**:
  - Validación de campos requeridos
  - Guardado en Firestore
  - Mensajes de confirmación/error
  - Estados de carga
  - Botón de cancelar para descartar cambios

### 2. Pestaña de Estadísticas
- **Selector de métricas** (solo 3 métricas reales):
  - ✅ Calorías consumidas (datos reales de Firestore)
  - ✅ Ejercicios realizados (datos reales de registros de ejercicio)
  - ✅ Días activos (datos reales calculados)

- **Selector de período**:
  - Última semana
  - Último mes
  - Último año

- **Gráficos visuales**:
  - Gráfico de líneas interactivo (usando fl_chart)
  - **Datos reales** obtenidos de Firestore
  - Diseño minimalista con gradientes
  - Estado de carga mientras obtiene datos

- **Resumen estadístico**:
  - Total acumulado (real)
  - Promedio del período (real)
  - Mejor día registrado (real)

- **Progreso personalizado**:
  - Mensaje motivacional según la métrica
  - Barra de progreso visual basada en objetivos realistas
  - Porcentaje de completitud calculado

## Diseño y UX

### Estilo Minimalista
- Paleta de colores: Blanco, negro y grises
- Tipografía: Pesos variables para jerarquía visual
- Espaciado consistente (múltiplos de 8)
- Bordes redondeados (12px radius)
- Sombras sutiles

### Componentes Reutilizables
- `_buildProfileField()`: Campos de texto con estado habilitado/deshabilitado
- `_buildDropdownField()`: Selectores dropdown personalizados
- `_buildDateField()`: Selector de fecha personalizado
- `_buildStatCard()`: Tarjetas de estadísticas
- `_buildMainChart()`: Gráfico principal configurable

### Interacciones
- Transiciones suaves entre pestañas
- Estados de carga con indicadores
- Feedback visual inmediato
- Validación en tiempo real

## Estructura de Archivos

```
lib/
├── ui/
│   ├── screens/
│   │   └── profile/
│   │       └── profile_screen.dart         # Pantalla principal con TabBar
│   └── widgets/
│       └── profile/
│           ├── profile_tab.dart            # Pestaña de edición de perfil
│           └── statistics_tab.dart         # Pestaña de estadísticas (datos reales)
├── data/
│   ├── models/
│   │   ├── user_profile.dart              # Modelo actualizado con nuevos campos
│   │   ├── food_entry.dart                # Modelo para entradas de alimentos
│   │   └── exercise_log.dart              # Modelo para registros de ejercicio
│   └── repositories/
│       ├── user_repository.dart           # Repositorio para perfiles
│       ├── food_repository.dart           # Repositorio para alimentación
│       └── exercise_repository.dart       # Repositorio para ejercicios
└── viewmodel/
    ├── user_viewmodel.dart                # ViewModel de usuario
    └── statistics_viewmodel.dart          # ViewModel para estadísticas reales
```

## Configuración de Base de Datos

### Modelo UserProfile
```dart
class UserProfile {
  final String uid;
  final String username;      // 🔒 No editable
  final String firstName;     // ✅ Editable
  final String lastName;      // ✅ Editable
  final String email;         // 🔒 No editable
  final String gender;        // ✅ Editable
  final DateTime birthDate;   // ✅ Editable
  final String profileType;   // ✅ Editable
  final String region;        // ✅ Editable
  final String language;      // ✅ Editable
}
```

### Reglas de Firestore
Las reglas de seguridad están configuradas para que solo el usuario autenticado pueda acceder y modificar su propio perfil.

## Dependencias Agregadas
- `fl_chart: ^0.69.0` - Para gráficos estadísticos

## Próximos Pasos Sugeridos

1. **✅ Estadísticas reales implementadas**: Calorías, ejercicios y días activos con datos reales de Firestore
2. **✅ Correcciones de errores**: Intervalos de gráfico y setState durante build solucionados
3. **✅ UI mejorada**: Botón de regresar y título removidos, navegación más limpia
4. **✅ Gráficos optimizados**: Menos puntos para mejor visualización (mes: 6 puntos, año: 12 puntos)
5. **✅ Detección de días activos mejorada**: Mejor lógica para detectar actividad diaria
6. **Carga de avatar**: Implementar funcionalidad para subir/cambiar foto de perfil
7. **Configuraciones adicionales**: Añadir más opciones de personalización
8. **Exportar estadísticas**: Permitir exportar datos en diferentes formatos
9. **Notificaciones**: Configurar preferencias de notificaciones

## Notas Técnicas

- Compatibilidad hacia atrás mantenida en `UserProfile.fromMap()`
- Gestión de estados con Provider
- Validación robusta de formularios
- Manejo de errores y estados de carga
- Código modular y reutilizable
- Seguimiento de mejores prácticas de Flutter
- **✅ Correcciones de errores de gráficos**: Manejo seguro de intervalos y datos vacíos
- **✅ Prevención de setState durante build**: Uso de PostFrameCallback para carga inicial
- **✅ Consultas de Firestore optimizadas**: Fallback entre Timestamp y String para compatibilidad
- **✅ Gráficos con menos puntos**: Semana (7 puntos), Mes (6 puntos), Año (12 puntos)
- **✅ Etiquetas de ejes mejoradas**: Días, rangos de días, y meses según el período
