using System.ComponentModel.DataAnnotations;

namespace ClinicaAPI.DTOs;

public class MedicoCreateDto
{
    [Required(ErrorMessage = "El nombre es obligatorio")]
    [StringLength(100, MinimumLength = 2)]
    public string Nombre { get; set; } = string.Empty;

    [Required(ErrorMessage = "El apellido es obligatorio")]
    [StringLength(100, MinimumLength = 2)]
    public string Apellido { get; set; } = string.Empty;

    [Required(ErrorMessage = "La especialidad es obligatoria")]
    [StringLength(100, MinimumLength = 3)]
    public string Especialidad { get; set; } = string.Empty;

    [Required(ErrorMessage = "El número de colegio médico es obligatorio")]
    [StringLength(20, MinimumLength = 3)]
    public string ColegioMedico { get; set; } = string.Empty;

    [Phone(ErrorMessage = "El teléfono no tiene un formato válido")]
    [StringLength(15)]
    public string Telefono { get; set; } = string.Empty;
}

public class MedicoUpdateDto : MedicoCreateDto { }

public class MedicoResponseDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Apellido { get; set; } = string.Empty;
    public string NombreCompleto => $"Dr. {Nombre} {Apellido}";
    public string Especialidad { get; set; } = string.Empty;
    public string ColegioMedico { get; set; } = string.Empty;
    public string Telefono { get; set; } = string.Empty;
}
