namespace ClinicaAPI.Models;

public enum EstadoCita
{
    Pendiente  = 1,
    Confirmada = 2,
    Cancelada  = 3,  // clínica/médico cancela (paciente no llegó, médico no pudo, etc.)
    Completada = 4,
    Anulada    = 5   // el propio paciente anuló la cita
}
