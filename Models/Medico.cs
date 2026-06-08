namespace ClinicaAPI.Models;

public class Medico
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Apellido { get; set; } = string.Empty;
    public string Especialidad { get; set; } = string.Empty;
    public string ColegioMedico { get; set; } = string.Empty;
    public string Telefono { get; set; } = string.Empty;
}
