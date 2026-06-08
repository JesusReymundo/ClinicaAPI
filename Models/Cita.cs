namespace ClinicaAPI.Models;

public enum EstadoCita
{
    Pendiente,
    Confirmada,
    Cancelada,
    Completada
}

public class Cita
{
    public int Id { get; set; }
    public int PacienteId { get; set; }
    public int MedicoId { get; set; }
    public DateTime FechaHora { get; set; }
    public string Motivo { get; set; } = string.Empty;
    public EstadoCita Estado { get; set; } = EstadoCita.Pendiente;
    public string? Observaciones { get; set; }

    public Paciente? Paciente { get; set; }
    public Medico? Medico { get; set; }
}
