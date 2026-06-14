using System.ComponentModel.DataAnnotations;

namespace ClinicaAPI.DTOs;

public class PacienteCreateDto
{
    [Required(ErrorMessage = "El nombre es obligatorio")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "El nombre debe tener entre 2 y 100 caracteres")]
    public string Nombre { get; set; } = string.Empty;

    [Required(ErrorMessage = "El apellido es obligatorio")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "El apellido debe tener entre 2 y 100 caracteres")]
    public string Apellido { get; set; } = string.Empty;

    [Required(ErrorMessage = "El DNI es obligatorio")]
    [StringLength(8, MinimumLength = 8, ErrorMessage = "El DNI debe tener exactamente 8 dígitos")]
    [RegularExpression(@"^\d{8}$", ErrorMessage = "El DNI debe contener solo dígitos")]
    public string Dni { get; set; } = string.Empty;

    [Phone(ErrorMessage = "El teléfono no tiene un formato válido")]
    [StringLength(15)]
    public string Telefono { get; set; } = string.Empty;

    [EmailAddress(ErrorMessage = "El email no tiene un formato válido")]
    [StringLength(150)]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "La fecha de nacimiento es obligatoria")]
    public DateTime FechaNacimiento { get; set; }

    [StringLength(5)]
    public string? GrupoSanguineo { get; set; }

    [StringLength(500)]
    public string? Alergias { get; set; }
}

public class PacienteUpdateDto : PacienteCreateDto { }

public class PacienteResponseDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Apellido { get; set; } = string.Empty;
    public string NombreCompleto => $"{Nombre} {Apellido}";
    public string Dni { get; set; } = string.Empty;
    public string Telefono { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public DateTime FechaNacimiento { get; set; }
    public string GrupoSanguineo { get; set; } = string.Empty;
    public string Alergias { get; set; } = string.Empty;
}
