using System.ComponentModel.DataAnnotations;
using ClinicaAPI.Models;

namespace ClinicaAPI.DTOs;

public class CitaCreateDto
{
    [Required(ErrorMessage = "El ID del paciente es obligatorio")]
    [Range(1, int.MaxValue, ErrorMessage = "El ID del paciente debe ser mayor a 0")]
    public int PacienteId { get; set; }

    [Required(ErrorMessage = "El ID del médico es obligatorio")]
    [Range(1, int.MaxValue, ErrorMessage = "El ID del médico debe ser mayor a 0")]
    public int MedicoId { get; set; }

    [Required(ErrorMessage = "La fecha y hora de la cita es obligatoria")]
    public DateTime FechaHora { get; set; }

    [Required(ErrorMessage = "El motivo de la cita es obligatorio")]
    [StringLength(300, MinimumLength = 5, ErrorMessage = "El motivo debe tener entre 5 y 300 caracteres")]
    public string Motivo { get; set; } = string.Empty;

    [StringLength(500)]
    public string? Observaciones { get; set; }
}

public class CitaUpdateDto : CitaCreateDto
{
    [Required(ErrorMessage = "El estado de la cita es obligatorio")]
    public EstadoCita Estado { get; set; }
}

public class CitaResponseDto
{
    public int Id { get; set; }
    public int PacienteId { get; set; }
    public string NombrePaciente { get; set; } = string.Empty;
    public int MedicoId { get; set; }
    public string NombreMedico { get; set; } = string.Empty;
    public string EspecialidadMedico { get; set; } = string.Empty;
    public DateTime FechaHora { get; set; }
    public string Motivo { get; set; } = string.Empty;
    public EstadoCita Estado { get; set; }
    public string? Observaciones { get; set; }
}
