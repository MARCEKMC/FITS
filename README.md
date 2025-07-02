# 🏃‍♀️ FITS - Aplicación de Salud y Bienestar Integral

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
</div>

## 📋 Tabla de Contenidos

- [🎯 Objetivo del Proyecto](#-objetivo-del-proyecto)
- [📱 Funcionalidades](#-funcionalidades)
- [🛠️ Tecnologías Utilizadas](#️-tecnologías-utilizadas)
- [⚙️ Arquitectura del Sistema](#️-arquitectura-del-sistema)
- [📊 Análisis de Requisitos](#-análisis-de-requisitos)
- [🔄 Metodología de Desarrollo](#-metodología-de-desarrollo)
- [🚀 Sprints y Desarrollo](#-sprints-y-desarrollo)
- [🤖 Integración con IA](#-integración-con-ia)
- [🔧 Instalación y Configuración](#-instalación-y-configuración)
- [📸 Screenshots](#-screenshots)
- [👥 Equipo de Desarrollo](#-equipo-de-desarrollo)
- [🔮 Trabajo Futuro](#-trabajo-futuro)

---

## 🎯 Objetivo del Proyecto

**FITS** es una aplicación móvil integral de salud y bienestar diseñada para ayudar a los usuarios a llevar un estilo de vida saludable y organizado. La aplicación combina el seguimiento nutricional, gestión de ejercicios, organización personal y asistencia inteligente con IA en una sola plataforma.

### 🌟 Visión
Crear una solución tecnológica que empodere a las personas para tomar control de su salud física y mental, proporcionando herramientas intuitivas respaldadas por inteligencia artificial.

### 🎯 Misión
Desarrollar una aplicación móvil que integre el seguimiento de salud, gestión personal y asistencia inteligente para mejorar la calidad de vida de los usuarios de manera sostenible.

---

## � Funcionalidades

### 🏠 **Módulo Home**
- **Dashboard personalizado** con resumen de actividades diarias
- **Acceso rápido** a todas las funcionalidades principales
- **Estadísticas visuales** de progreso

### 🍎 **Módulo de Salud (Health)**
- **Seguimiento nutricional** con base de datos de alimentos
- **Cálculo automático de calorías** y macronutrientes
- **Registro de consumo de agua** con recordatorios
- **Biblioteca de ejercicios** organizados por grupos musculares
- **Reproductor de ejercicios** con temporizadores
- **Reportes de salud automáticos** generados por IA

### ⚡ **Módulo de Eficiencia (Efficiency)**
- **Gestión de tareas** con prioridades y fechas límite
- **Sistema de notas** regulares y seguras con PIN
- **Organizador de actividades** y horarios
- **Análisis de productividad** con IA

### 📊 **Módulo de Perfil y Estadísticas**
- **Perfil de usuario** editable con validaciones
- **Estadísticas visuales** con gráficos interactivos
- **Seguimiento de progreso** a largo plazo
- **Métricas de calorías y ejercicios**

### 🤖 **Asistente IA - Fitsi**
- **Chat inteligente** con personalidad femenina amigable
- **Comandos de voz** para agregar datos
- **Reportes automáticos** de salud y productividad
- **Ejercicios personalizados** bajo demanda
- **Análisis contextual** de datos del usuario

---

## 🛠️ Tecnologías Utilizadas

### **Frontend**
```dart
- Flutter 3.24.0
- Dart 3.4.0
- Material Design 3
- Provider (State Management)
- FL Chart (Gráficos)
```

### **Backend & Base de Datos**
```firebase
- Firebase Authentication
- Cloud Firestore
- Firebase Security Rules
```

### **Inteligencia Artificial**
```openai
- OpenAI GPT-4o
- Procesamiento de lenguaje natural
- Generación de reportes automáticos
```

### **Herramientas de Desarrollo**
```tools
- Visual Studio Code
- Git & GitHub
- Flutter DevTools
- Firebase Console
- Postman (API Testing)
```

---

## ⚙️ Arquitectura del Sistema

### **Patrón MVVM (Model-View-ViewModel)**
```
lib/
├── data/
│   ├── models/           # Modelos de datos
│   └── services/         # Servicios de API
├── ui/
│   ├── screens/          # Pantallas principales
│   ├── widgets/          # Componentes reutilizables
│   └── theme/            # Configuración de tema
├── viewmodel/            # Lógica de negocio
└── utils/                # Utilidades y helpers
```

### **Arquitectura de Base de Datos**
```firestore
Collection: users
├── health_profiles
├── food_entries
├── water_entries
├── exercise_logs
├── notes
├── secure_notes
├── tasks
└── user_settings
```

Firebase – Autenticación, Firestore, Storage, FCM.

OpenAI API – Integración con GPT para el bot FITSI.

Room DB – Base de datos local para modo offline.

GitHub Actions – Integración y despliegue continuo (CI/CD).

Dart – Lenguaje de programación principal.

⚙️ Instalación y Ejecución
Clona el repositorio:
git clone https://github.com/tu-usuario/fits.git

Abre el proyecto en VSCode o Android Studio.

Asegúrate de tener configurado Flutter y Dart en tu entorno.

Agrega tu archivo google-services.json dentro de:
android/app/

Ejecuta el proyecto:
flutter pub get
flutter run
```

---

## 📊 Análisis de Requisitos

### **Requisitos Funcionales**

| RF-001 | **Autenticación de Usuario** |
|--------|------------------------------|
| Descripción | El sistema debe permitir registro e inicio de sesión |
| Prioridad | Alta |
| Estado | ✅ Implementado |

| RF-002 | **Seguimiento Nutricional** |
|--------|----------------------------|
| Descripción | Registrar alimentos y calcular calorías automáticamente |
| Prioridad | Alta |
| Estado | ✅ Implementado |

| RF-003 | **Gestión de Ejercicios** |
|--------|--------------------------|
| Descripción | Biblioteca de ejercicios con reproductor integrado |
| Prioridad | Alta |
| Estado | ✅ Implementado |

| RF-004 | **Asistente IA** |
|--------|--------------------|
| Descripción | Chat inteligente con comandos de voz y reportes |
| Prioridad | Media |
| Estado | ✅ Implementado |

### **Requisitos No Funcionales**

| RNF-001 | **Rendimiento** |
|---------|-----------------|
| Criterio | Tiempo de respuesta < 2 segundos |
| Medición | Probado en dispositivos Android |
| Estado | ✅ Cumplido |

| RNF-002 | **Seguridad** |
|---------|---------------|
| Criterio | Autenticación Firebase + Firestore Rules |
| Implementación | Validación en frontend y backend |
| Estado | ✅ Cumplido |

| RNF-003 | **Usabilidad** |
|---------|----------------|
| Criterio | Interfaz intuitiva siguiendo Material Design |
| Evaluación | Navegación clara y componentes familiares |
| Estado | ✅ Cumplido |

### **Requisitos de Calidad**

| RQ-001 | **Mantenibilidad** |
|--------|--------------------|
| Implementación | Arquitectura MVVM + Documentación |
| Métricas | Código modular y reutilizable |
| Estado | ✅ Cumplido |

| RQ-002 | **Escalabilidad** |
|--------|-------------------|
| Diseño | Base de datos NoSQL + Servicios en la nube |
| Capacidad | Soporta crecimiento de usuarios |
| Estado | ✅ Cumplido |

---

## 🔄 Metodología de Desarrollo

### **Scrum Adaptado**
- **Duración del proyecto**: 6 semanas
- **Sprints**: 6 sprints de 1 semana cada uno
- **Reuniones**: Domingos 2:00 PM (20 minutos)
- **Roles**: Product Owner, Scrum Master, Developers

### **Herramientas de Gestión**
- **Repositorio**: GitHub con ramas por feature
- **Comunicación**: Google Meet + Discord
- **Documentación**: Markdown + Comentarios en código

---

## 🚀 Sprints y Desarrollo

### **Sprint 1 (Semana 1) - Fundación** 🏗️
**Objetivo**: Establecer la base del proyecto y autenticación

**Tareas Completadas**:
- ✅ Configuración inicial de Flutter
- ✅ Integración con Firebase Authentication
- ✅ Diseño de la arquitectura MVVM
- ✅ Pantallas de login y registro
- ✅ Configuración de Firestore

**Commits principales**:
```bash
- feat: initial flutter project setup
- feat: firebase authentication integration
- feat: login and register screens
- docs: project structure documentation
```

**Sprint Review**: ✅ Autenticación funcional, base sólida establecida

---

### **Sprint 2 (Semana 2) - Navegación y UI** 🎨
**Objetivo**: Implementar navegación principal y diseño base

**Tareas Completadas**:
- ✅ Sistema de navegación bottom navigation
- ✅ Pantalla Home con dashboard
- ✅ Tema y colores de la aplicación
- ✅ Componentes reutilizables base

**Commits principales**:
```bash
- feat: bottom navigation implementation
- feat: home dashboard layout
- style: material design theme setup
- refactor: reusable widgets creation
```

**Sprint Review**: ✅ Navegación fluida, UI consistente establecida

---

### **Sprint 3 (Semana 3) - Módulo de Salud** 🏥
**Objetivo**: Implementar seguimiento nutricional y de agua

**Tareas Completadas**:
- ✅ Base de datos de alimentos
- ✅ Registro de comidas con cálculo de calorías
- ✅ Seguimiento de consumo de agua
- ✅ Modelos de datos para health_profiles
- ✅ Validaciones y reglas de Firestore

**Commits principales**:
```bash
- feat: food database and nutrition tracking
- feat: water intake monitoring
- feat: health profile management
- security: firestore security rules
```

**Sprint Review**: ✅ Seguimiento nutricional completo y funcional

---

### **Sprint 4 (Semana 4) - Ejercicios y Eficiencia** 💪
**Objetivo**: Biblioteca de ejercicios y gestión de tareas

**Tareas Completadas**:
- ✅ Biblioteca de ejercicios por grupos musculares
- ✅ Reproductor de ejercicios con temporizadores
- ✅ Gestión de tareas y notas
- ✅ Sistema de notas seguras con PIN
- ✅ Registro de ejercicios completados

**Commits principales**:
```bash
- feat: exercise library and player
- feat: task management system
- feat: secure notes with PIN protection
- feat: exercise completion tracking
```

**Sprint Review**: ✅ Módulos de ejercicio y productividad operativos

---

### **Sprint 5 (Semana 5) - Estadísticas y Perfil** 📊
**Objetivo**: Sistema de estadísticas y gestión de perfil

**Tareas Completadas**:
- ✅ Perfil de usuario editable
- ✅ Gráficos interactivos con FL Chart
- ✅ Estadísticas de calorías y ejercicios
- ✅ Sistema de métricas temporales
- ✅ Validaciones de formularios

**Commits principales**:
```bash
- feat: user profile management
- feat: interactive statistics charts
- feat: exercise and nutrition metrics
- fix: chart data visualization improvements
```

**Sprint Review**: ✅ Sistema de estadísticas robusto implementado

---

### **Sprint 6 (Semana 6) - IA y Optimización** 🤖
**Objetivo**: Integración de IA y optimizaciones finales

**Tareas Completadas**:
- ✅ Integración con OpenAI GPT-4o
- ✅ Asistente IA "Fitsi" con personalidad
- ✅ Comandos de voz para agregar datos
- ✅ Reportes automáticos de salud y productividad
- ✅ Optimizaciones de rendimiento
- ✅ Testing y corrección de bugs

**Commits principales**:
```bash
- feat: OpenAI GPT-4o integration
- feat: Fitsi AI assistant implementation
- feat: automated health and productivity reports
- feat: voice commands for data entry
- perf: app performance optimizations
- docs: comprehensive README documentation
```

**Sprint Review**: ✅ IA totalmente integrada, aplicación lista para producción

---

## 🤖 Integración con IA

### **Fitsi - Asistente Inteligente**
```typescript
Características:
- Personalidad femenina amigable y ligeramente tímida
- Procesamiento de comandos en lenguaje natural
- Generación de reportes contextuales
- Recomendaciones personalizadas basadas en datos
```

### **Funcionalidades de IA**
```markdown
1. **Comandos de Voz**:
   - "Agrega una nota: Reunión mañana"
   - "Comí 200g de pollo con arroz"
   - "Hazme un ejercicio de pecho"

2. **Reportes Automáticos**:
   - Análisis nutricional con predicciones de salud
   - Evaluación de productividad y sugerencias
   - Detección de patrones y alertas

3. **Ejercicios Personalizados**:
   - Generación de rutinas adaptadas
   - Recomendaciones basadas en historial
   - Ajustes según preferencias del usuario
```

### **Configuración Técnica**
```properties
OPENAI_API_KEY=sk-proj-[KEY]
FITSI_MODEL=gpt-4o
FITSI_MAX_TOKENS=500
FITSI_TEMPERATURE=0.7
```

---

## 🔧 Instalación y Configuración

### **Prerrequisitos**
```bash
- Flutter SDK 3.24.0+
- Dart 3.4.0+
- Android Studio / VS Code
- Git
```

### **Configuración del Proyecto**
```bash
# 1. Clonar repositorio
git clone https://github.com/tu-usuario/fits.git
cd fits

# 2. Instalar dependencias
flutter pub get

# 3. Configurar Firebase
# - Agregar google-services.json en android/app/
# - Configurar firebase_options.dart

# 4. Configurar OpenAI
# - Crear archivo .env con tu API key
# - Agregar límites de uso recomendados

# 5. Ejecutar aplicación
flutter run
```

### **Variables de Entorno (.env)**
```properties
OPENAI_API_KEY=tu-api-key-aqui
FITSI_MODEL=gpt-4o
FITSI_MAX_TOKENS=500
FITSI_TEMPERATURE=0.7
```

---

## 📸 Screenshots

<div align="center">
  <table>
    <tr>
      <td align="center">
        <h4>🏠 Home Dashboard</h4>
        <p>Resumen diario de actividades</p>
      </td>
      <td align="center">
        <h4>🍎 Nutrición</h4>
        <p>Seguimiento de alimentos y calorías</p>
      </td>
    </tr>
    <tr>
      <td align="center">
        <h4>💪 Ejercicios</h4>
        <p>Biblioteca y reproductor de ejercicios</p>
      </td>
      <td align="center">
        <h4>🤖 Fitsi IA</h4>
        <p>Asistente inteligente personalizado</p>
      </td>
    </tr>
  </table>
</div>

---

## 👥 Equipo de Desarrollo

### **Roles y Responsabilidades**

| Rol | Responsabilidades | Herramientas |
|-----|------------------|--------------|
| **Product Owner** | Definición de requisitos, priorización de features | Scrum Framework |
| **Scrum Master** | Facilitación de reuniones, eliminación de impedimentos | Meet, Discord |
| **Lead Developer** | Arquitectura, integración de IA, revisión de código | Flutter, OpenAI |
| **Frontend Developer** | Interfaces de usuario, componentes, navegación | Flutter, Material Design |
| **Backend Developer** | Firebase, base de datos, autenticación | Firestore, Auth |

### **Ceremonias Implementadas**
```markdown
- **Sprint Planning**: Domingos 2:00 PM (15 min)
- **Daily Stand-up**: Async via Discord
- **Sprint Review**: Domingos 2:15 PM (5 min)
- **Retrospective**: Al final de cada sprint
```

---

## 🔮 Trabajo Futuro

### **Próximas Funcionalidades** (Roadmap)
```markdown
📱 **Versión 2.0**:
- [ ] Sincronización con dispositivos wearables
- [ ] Redes sociales y comunidad de usuarios
- [ ] Modo offline completo
- [ ] Notificaciones push inteligentes

🤖 **IA Avanzada**:
- [ ] Reconocimiento de imágenes para alimentos
- [ ] Análisis de sentimientos en notas
- [ ] Predicciones de salud a largo plazo
- [ ] Entrenador personal IA

📊 **Analytics**:
- [ ] Dashboard de administración
- [ ] Métricas de uso de la aplicación
- [ ] A/B testing para UI/UX
- [ ] Reportes de engagement
```

### **Mejoras Técnicas**
```markdown
🔧 **Optimizaciones**:
- [ ] Migración a Flutter 3.25+
- [ ] Implementación de tests unitarios completos
- [ ] CI/CD con GitHub Actions
- [ ] Monitoreo de performance con Firebase Analytics

🛡️ **Seguridad**:
- [ ] Cifrado end-to-end para notas seguras
- [ ] Autenticación biométrica
- [ ] Auditoría de seguridad completa
- [ ] Cumplimiento GDPR
```

---

## 📜 Licencia

Este proyecto fue desarrollado como parte de un proyecto académico/personal. 

**Tecnologías de terceros utilizadas**:
- Flutter (BSD License)
- Firebase (Google Terms)
- OpenAI API (OpenAI Terms)
- FL Chart (BSD License)

---

## 🙏 Agradecimientos

Agradecemos a:
- **Google Flutter Team** por el framework excepcional
- **Firebase Team** por la infraestructura robusta
- **OpenAI** por hacer accesible la IA avanzada
- **Comunidad Flutter** por recursos y soporte
- **Material Design** por las guías de diseño

---

<div align="center">
  <h3>🏃‍♀️ ¡Gracias por usar FITS!</h3>
  <p>Construido con ❤️ usando Flutter y mucho ☕</p>
  
  **⭐ Si te gusta el proyecto, dale una estrella en GitHub ⭐**
</div>

---

**Última actualización**: Julio 2025  
**Versión**: 1.0.0  
**Estado**: ✅ Producción
