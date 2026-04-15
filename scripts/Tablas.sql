-- 1. Tabla de Usuarios
CREATE TABLE Usuarios (
    Correo VARCHAR2(100) CONSTRAINT pk_usuarios PRIMARY KEY,
    Nombre VARCHAR2(50) NOT NULL,
    Apelli VARCHAR2(100) NOT NULL
);

-- 2. Tabla General de Zonas (Superclase)
CREATE TABLE Zonas (
    Id_zona NUMBER CONSTRAINT pk_zonas PRIMARY KEY,
    Tipo VARCHAR2(50) NOT NULL,
    m2 NUMBER(10,2)
);

-- 3. Tablas de las Subclases de Zonas
CREATE TABLE Piscina (
    Id_zona NUMBER CONSTRAINT pk_piscina PRIMARY KEY,
    N_Sombrillas NUMBER,
    CONSTRAINT fk_piscina_zona FOREIGN KEY (Id_zona) REFERENCES Zonas(Id_zona) ON DELETE CASCADE
);

CREATE TABLE BBQ (
    Id_zona NUMBER CONSTRAINT pk_bbq PRIMARY KEY,
    Menu VARCHAR2(200),
    CONSTRAINT fk_bbq_zona FOREIGN KEY (Id_zona) REFERENCES Zonas(Id_zona) ON DELETE CASCADE
);

CREATE TABLE Premium (
    Id_zona NUMBER CONSTRAINT pk_premium PRIMARY KEY,
    N_pistolas NUMBER,
    CONSTRAINT fk_premium_zona FOREIGN KEY (Id_zona) REFERENCES Zonas(Id_zona) ON DELETE CASCADE
);

-- 4. Tabla de Reservas
CREATE TABLE Reservas (
    Id_r NUMBER CONSTRAINT pk_reservas PRIMARY KEY,
    Correo VARCHAR2(100) NOT NULL,
    Zona NUMBER NOT NULL,
    F_ini DATE NOT NULL,
    F_fin DATE NOT NULL,
    CONSTRAINT fk_reserva_correo FOREIGN KEY (Correo) REFERENCES Usuarios(Correo),
    CONSTRAINT fk_reserva_zona FOREIGN KEY (Zona) REFERENCES Zonas(Id_zona)
);