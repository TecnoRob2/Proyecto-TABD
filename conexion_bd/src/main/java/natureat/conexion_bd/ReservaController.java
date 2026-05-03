package natureat.conexion_bd;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import javax.sql.DataSource;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class ReservaController {

    private final DataSource dataSource;

    public ReservaController(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @PostMapping("/realizarReserva")
    public String realizarReserva(
            @RequestParam String nombre,
            @RequestParam String apellidos,
            @RequestParam String correo,
            @RequestParam String tipoZona,
            @RequestParam int numeroZona,
            @RequestParam String f_ini, 
            @RequestParam String f_fin
    ) {
        
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        LocalDateTime fechaHoraInicio = LocalDateTime.parse(f_ini, formatter);
        LocalDateTime fechaHoraFin = LocalDateTime.parse(f_fin, formatter);

        // Consultas SQL preparadas
        String sqlCheckUser = "SELECT COUNT(*) FROM Usuarios WHERE Correo = ?";
        String sqlInsertUser = "INSERT INTO Usuarios (Correo, Nombre, Apelli) VALUES (?, ?, ?)";
        String sqlUpdateUser = "UPDATE Usuarios SET Nombre = ?, Apelli = ? WHERE Correo = ?";
        
        String sqlInsertReserva = "INSERT INTO Reservas (Correo, Zona, F_ini, F_fin) VALUES (?, ?, ?, ?)";

        // Abrimos UNICA conexión para hacer todas las operaciones
        try (Connection conn = dataSource.getConnection()) {
             
            // ==========================================
            // PASO 1: GESTIONAR EL USUARIO
            // ==========================================
            boolean usuarioExiste = false;
            
            // Comprobar si existe
            try (PreparedStatement pstmtCheck = conn.prepareStatement(sqlCheckUser)) {
                pstmtCheck.setString(1, correo);
                try (ResultSet rs = pstmtCheck.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        usuarioExiste = true;
                    }
                }
            }

            if (usuarioExiste) {
                // Existe -> Actualizamos sus datos
                try (PreparedStatement pstmtUpdate = conn.prepareStatement(sqlUpdateUser)) {
                    pstmtUpdate.setString(1, nombre);
                    pstmtUpdate.setString(2, apellidos);
                    pstmtUpdate.setString(3, correo);
                    pstmtUpdate.executeUpdate();
                }
            } else {
                // No existe -> Lo creamos nuevo
                try (PreparedStatement pstmtInsert = conn.prepareStatement(sqlInsertUser)) {
                    pstmtInsert.setString(1, correo);
                    pstmtInsert.setString(2, nombre);
                    pstmtInsert.setString(3, apellidos);
                    pstmtInsert.executeUpdate();
                }
            }

            // ==========================================
            // PASO 2: INSERTAR LA RESERVA
            // ==========================================
            try (PreparedStatement pstmtReserva = conn.prepareStatement(sqlInsertReserva)) {
                pstmtReserva.setString(1, correo);
                pstmtReserva.setInt(2, numeroZona);
                pstmtReserva.setTimestamp(3, java.sql.Timestamp.valueOf(fechaHoraInicio));
                pstmtReserva.setTimestamp(4, java.sql.Timestamp.valueOf(fechaHoraFin));
                
                pstmtReserva.executeUpdate();
            }
            
            return "Usuario procesado y reserva guardada correctamente";
            
        } catch (SQLException e) {
            e.printStackTrace();
            return "Error en la base de datos: " + e.getMessage();
        }
    }
}